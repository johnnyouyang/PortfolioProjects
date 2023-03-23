/*
Cleaning data in SQL queries

*/
select *
from Portfolio..NashvilleHousing

-- Standardize Date Format
select SaleDate, convert(date, saledate)
from Portfolio..NashvilleHousing

-- Since cannot convert the SaleDate column directly
alter table NashvilleHousing
add SaleDateConverted Date


update NashvilleHousing
set SaleDateConverted = convert(date, saledate)

-- Populate property address data
select *
from Portfolio..NashvilleHousing
where PropertyAddress is null
order by ParcelID


-- self join table to replace the null value
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio..NashvilleHousing a
join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio..NashvilleHousing a
join Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out property address into individual columns
select PropertyAddress
from Portfolio..NashvilleHousing


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',' , PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress) 
from Portfolio..NashvilleHousing


alter table Portfolio..NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update Portfolio..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',' , PropertyAddress)-1)

alter table Portfolio..NashvilleHousing
add PropertySplitCity Nvarchar(255)

update Portfolio..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

-- Breaking out owner address into individual columns
select
PARSENAME(REPLACE(owneraddress, ',', '.'),3),
PARSENAME(REPLACE(owneraddress, ',', '.'),2),
PARSENAME(REPLACE(owneraddress, ',', '.'),1)
from Portfolio..NashvilleHousing

alter table Portfolio..NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update Portfolio..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'),3)

alter table Portfolio..NashvilleHousing
add OwnerSplitCity Nvarchar(255)

update Portfolio..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'),2)

alter table Portfolio..NashvilleHousing
add OwnerSplitState Nvarchar(255)

update Portfolio..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'),1)



-- Change Y and N to Yes and No in "sold as vacant" field
select distinct(soldasvacant), COUNT(*)
from Portfolio..NashvilleHousing
group by soldasvacant
order by 2

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant 
	 end
from Portfolio..NashvilleHousing


update Portfolio..NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant 
	 end


-- remove duplicates
with RowNumCTE as(
select *, 
	ROW_NUMBER() over(
	partition by parcelID,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference 
				 order by
					uniqueID) row_num

from Portfolio..NashvilleHousing 
)

--delete
--from RowNumCTE
--where row_num > 1

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


--delete unused columns

select *
from Portfolio..NashvilleHousing 

alter table Portfolio..NashvilleHousing 
drop column owneraddress,taxdistrict, propertyaddress

alter table Portfolio..NashvilleHousing 
drop column saledate