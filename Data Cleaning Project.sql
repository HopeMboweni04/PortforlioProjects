/*
Cleaning Data in SQL Queries
*/

------SKILLS USED: Case Statement, CTEs, Partition By, ISNULL, ParseName and Replace, Convert, SubString, Distinct, Row_Number

Select *
from ProjectPortfolio..NashvilleHousing

--------Standardize Data Format
----follow each step

Select SaleDate, CONVERT(Date,SaleDate)
from ProjectPortfolio..NashvilleHousing

update NashvilleHousing
Set SaleDate = convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
Set SaleDateConverted = convert(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
from ProjectPortfolio..NashvilleHousing

------------------------------------------------------------------------------------------------------------

----Populate Property Address Data

Select *
from ProjectPortfolio..NashvilleHousing
order by ParcelID

Select T1.ParcelID, T1.PropertyAddress,T2.ParcelID,T2.PropertyAddress
from ProjectPortfolio..NashvilleHousing as T1
join ProjectPortfolio..NashvilleHousing as T2
on T1.ParcelID = T2.ParcelID
and T1.[UniqueID ] <> T2.[UniqueID ]
where T1.PropertyAddress is null

Select T1.ParcelID, T1.PropertyAddress,T2.ParcelID,T2.PropertyAddress, ISNULL(T1.PropertyAddress, T2.PropertyAddress) as PropertyUpdated
from ProjectPortfolio..NashvilleHousing as T1
join ProjectPortfolio..NashvilleHousing as T2
on T1.ParcelID = T2.ParcelID
and T1.[UniqueID ] <> T2.[UniqueID ]
where T1.PropertyAddress is null

update T1
set PropertyAddress = ISNULL(T1.PropertyAddress, T2.PropertyAddress)
from ProjectPortfolio..NashvilleHousing as T1
join ProjectPortfolio..NashvilleHousing as T2
on T1.ParcelID = T2.ParcelID
and T1.[UniqueID ] <> T2.[UniqueID ]
where T1.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------

------BREAKING ADDRESS, CITY AND STATE INTO INDIVIDUAL COLUMNS

----Spliting PropertyAdresss into two columns(Address and city)

Select PropertyAddress
from ProjectPortfolio..NashvilleHousing

select  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address ,
        SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as city
From ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitedAddress nvarchar(255);

update NashvilleHousing
Set PropertySplitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
add PropertySplitedCity nvarchar(255);

update NashvilleHousing
Set PropertySplitedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


----Spliting PropertyAdresss into two columns(Address, city and )

Select OwnerAddress
from ProjectPortfolio..NashvilleHousing

Select 
ParseName(Replace(OwnerAddress,',','.'), 3 )
,ParseName(Replace(OwnerAddress,',','.'), 2 ) 
,ParseName(Replace(OwnerAddress,',','.'), 1) 
from ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitedAddress nvarchar(255);

update NashvilleHousing
Set OwnerSplitedAddress = ParseName(Replace(OwnerAddress,',','.'), 3 )

ALTER TABLE NashvilleHousing
add OwnerSplitedCity nvarchar(255);

update NashvilleHousing
Set OwnerSplitedCity = ParseName(Replace(OwnerAddress,',','.'), 2 )

ALTER TABLE NashvilleHousing
add OwnerSplitedState nvarchar(255);

update NashvilleHousing
Set OwnerSplitedState = ParseName(Replace(OwnerAddress,',','.'), 1 )



---------------------------------------------------------------------------------------------------------------

----Change Y and N to Yes and No in "Sold as Vacant " field

Select Distinct(SoldAsVacant)
from ProjectPortfolio..NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from ProjectPortfolio..NashvilleHousing
Group by SoldAsVacant 
Order by 2


Select SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
from ProjectPortfolio..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE
                   WHEN SoldAsVacant = 'Y' THEN 'Yes'
                   WHEN SoldAsVacant = 'N' THEN 'NO'
	               ELSE SoldAsVacant
                   END


-------------------------------------------------------------------------------------------------------------------

---------------REMOVE DUPLICATES

-----Checking Duplicates

Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER BY UniqueID ) As row_num
from ProjectPortfolio..NashvilleHousing
ORDER BY ParcelID

--------Using CTEs where row_num > 1

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
   ORDER BY UniqueID ) As row_num
 from ProjectPortfolio..NashvilleHousing )
Select *
From RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

-------Deleting Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, 
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
   ORDER BY UniqueID ) As row_num
from ProjectPortfolio..NashvilleHousing )
DELETE
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------------------------

----Delete unused columns

Select *
from ProjectPortfolio..NashvilleHousing

 ALTER TABLE ProjectPortfolio..NashvilleHousing
 DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN SaleDate

-----------------------------------------------------------------------------------------------------------------------
