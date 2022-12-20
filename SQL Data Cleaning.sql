-- Data Cleaning (SQL Queries)

Select *
from PortfolioProject.dbo.NashvilleHousing

------------------------------
--Standardize Date Format
------------------------------

Select SaleDateConverted, CONVERT(Date,SaleDate) 
from PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER Table PortfolioProject.dbo.NashvilleHousing 
Add SaleDateConverted Date

UPDATE NashvilleHousing SET
SaleDateConverted = CONVERT(Date, SaleDate)

------------------------------------
--Populating Property Address Data
------------------------------------

Select * 
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
Order by ParcelID

Select a.ParcelID, a.propertyAddress, b.ParcelID,b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--Update

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing as a
join PortfolioProject.dbo.NashvilleHousing as b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

------------------------------------------------------------------------
--Breaking out Address into individual Columns (Address, City, States)
------------------------------------------------------------------------

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
--Order by ParcelID

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

ALTER table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress))

ALTER table NashvilleHousing
Add PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select * 
from NashvilleHousing

--Owner

Select OwnerAddress 
from NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

ALTER table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER table NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select * 
from NashvilleHousing

------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" Column
------------------------------------------------------------------------

Select Distinct(SoldasVacant), Count(SoldasVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by Soldasvacant
Order by 2

Select SoldasVacant,
CASE When SoldasVacant = 'Y' THEN 'Yes'
     When SoldasVacant = 'N' THEN 'No'
	 ELSE SoldasVacant
	 END
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldasVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
         When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldasVacant
		 END

------------------------------------
--Remove Duplicates
------------------------------------

With RowNumCTE  AS(
Select *,
	Row_Number() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by
		UniqueID
		) row_num
			
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select * from RowNumCTE
where row_num > 1
Order by PropertyAddress



With RowNumCTE  AS(
Select *,
	Row_Number() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by
		UniqueID
		) row_num
			
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
DELETE from RowNumCTE
where row_num > 1
--Order by PropertyAddress


With RowNumCTE  AS(
Select *,
	Row_Number() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by
		UniqueID
		) row_num
			
from PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
Order by PropertyAddress

------------------------------------
--Remove Unused Columns
------------------------------------
Select *
from PortfolioProject.dbo.NashvilleHousing

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, PropertyAddress,TaxDistrict,SaleDate