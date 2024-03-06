/*

Cleaning Data in SQL Queries

*/


Select *
From HousingProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate) 
From HousingProject..NashvilleHousing

UPDATE HousingProject..NashvilleHousing
SET SaleDate = CONVERT (Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE HousingProject..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE HousingProject..NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM HousingProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM HousingProject..NashvilleHousing a
JOIN HousingProject..NashvilleHousing b
	ON a.ParcelID = b.[ParcelID]
	AND a.[UniqueID ] <>b.[UniqueID ]
WHERE a.PropertyAddress is null



UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM HousingProject..NashvilleHousing a
JOIN HousingProject..NashvilleHousing b
	ON a.ParcelID = b.[ParcelID]
	AND a.[UniqueID ] <>b.[UniqueID ]
WHERE a. PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM HousingProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID


SELECT 
SUBSTRING (PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) AS Address
FROM HousingProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySlipAddress Nvarchar(255);


UPDATE HousingProject..NashvilleHousing
SET PropertySlipAddress = SUBSTRING (PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


UPDATE HousingProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))


SELECT *
FROM HousingProject..NashvilleHousing

SELECT OwnerAddress
FROM HousingProject..NashvilleHousing


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3) 
, PARSENAME (REPLACE(OwnerAddress, ',', '.'),2) 
, PARSENAME (REPLACE(OwnerAddress, ',', '.'),1) 
FROM HousingProject..NashvilleHousing


ALTER TABLE HousingProject..NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

UPDATE HousingProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', '.'),3) 

ALTER TABLE HousingProject..NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

UPDATE HousingProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', '.'),2) 

ALTER TABLE HousingProject..NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

UPDATE HousingProject..NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1) 

SELECT *
FROM HousingProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field



SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM HousingProject..NashvilleHousing



UPDATE HousingProject..NashvilleHousing
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) Row_Num
FROM HousingProject..NashvilleHousing
--ORDER BY ParcelID 
)
SELECT *
FROM RowNumCTE
WHERE Row_num > 1



SELECT *
FROM HousingProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE HousingProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingProject..NashvilleHousing
DROP COLUMN SaleDate

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------