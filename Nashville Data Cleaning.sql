use [Housing Data Cleaning];

select *
from Nashville_Housing;

-------------------------------------------------------------
-- Standardizing Date Format

select SaleDate, CONVERT(Date,SaleDate)
from Nashville_Housing;


alter table Nashville_Housing
add SaleDateConverted Date;

update Nashville_Housing
set SaleDateConverted = Convert(DATE,SaleDate);


select top(5) *
from Nashville_Housing;
--------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data
select *
from Nashville_Housing
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--update null values with property address
Update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;


--------------------------------------------------------------------------------------------------------------------------

--Break out Property Address into individual columns (Address, & City)

select PropertyAddress
from Nashville_Housing;

select
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1)) as Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress)+1),LEN(PropertyAddress)) as City
from Nashville_Housing


--Updating the table w/ separated data 
alter table Nashville_Housing
add PropertySplitAddress nvarchar(255);

update Nashville_Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1));

alter table Nashville_Housing
add PropertySplitCity nvarchar(255);

update Nashville_Housing
set PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress)+1),LEN(PropertyAddress));


--------------------------------------------------------------------------------------------------------------------------

--Break out Owner Address into individual columns (Address, City, & State)


select OwnerAddress
from Nashville_Housing;

Select PARSENAME(Replace(OwnerAddress, ',', '.' ), 3),
PARSENAME(Replace(OwnerAddress, ',', '.' ), 2),
PARSENAME(Replace(OwnerAddress, ',', '.' ), 1)
from Nashville_Housing


--Updating the table w/ separated data 
alter table Nashville_Housing
add OwnerSplitAddress nvarchar(255);

update Nashville_Housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.' ), 3);

alter table Nashville_Housing
add OwnerSplitCity nvarchar(255);

update Nashville_Housing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.' ), 2);

alter table Nashville_Housing
add OwnerSplitState nvarchar(255);

update Nashville_Housing
set OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.' ), 1);


--------------------------------------------------------------------------------------------------------------------------

-- Change Y & N to Yes and No in 'sold as vacant' field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by 2;


select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
from Nashville_Housing;


update Nashville_Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end;



--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as(
select *,
	row_number() over (
	Partition by ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference
				order by UniqueID) row_num
from Nashville_Housing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num >1;


--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select * from Nashville_Housing;

alter table Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
