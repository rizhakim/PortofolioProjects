/*

Cleaning Data in SQL Queries

*/


Select *
FROM PortofolioProject..NashvilleHousing



-- Standardize Date Format

SELECT SaleDate, CONVERT(Date,Saledate)
FROM PortofolioProject..NashvilleHousing

UPDATE PortofolioProject..NashvilleHousing
SET Saledate = CONVERT(Date,Saledate)


ALTER TABLE PortofolioProject..NashvilleHousing
ADD SaleDateConverted Date

UPDATE PortofolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT (Date,Saledate)


--Populate Property Address Data

SELECT *
FROM PortofolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.UniqueID <> b.UniqueID

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) Using Substring

SELECT PropertyAddress
FROM PortofolioProject..NashvilleHousing


SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address,
	LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress))) AS City
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE PortofolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE PortofolioProject..NashvilleHousing
SET PropertySplitCity = LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1, LEN(PropertyAddress)))

SELECT *
FROM PortofolioProject..NashvilleHousing

-- Breaking out Address into Individual Columns (Address, City, State) Using Parsename

SELECT OwnerAddress
FROM PortofolioProject..NashvilleHousing

SELECT PARSENAME (Replace(OwnerAddress, ',','.'), 3), 
	PARSENAME (Replace(OwnerAddress, ',','.'), 2),
	PARSENAME (Replace(OwnerAddress, ',','.'), 1),
	OwnerAddress
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress, ',','.'), 3)


ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitCity =  PARSENAME (Replace(OwnerAddress, ',','.'), 2)


ALTER TABLE PortofolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE PortofolioProject..NashvilleHousing
SET OwnerSplitState =  PARSENAME (Replace(OwnerAddress, ',','.'), 1)

SELECT *
FROM PortofolioProject..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), count(SoldAsVacant)
FROM PortofolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortofolioProject..NashvilleHousing


UPDATE PortofolioProject..NashvilleHousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END




--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Check if wether there is duplicate unique ID

Select Distinct(UniqueID), count(UniqueID) AS CountUniqID
FROM PortofolioProject..NashvilleHousing
Group By UniqueID
Having count(UniqueID) > 1

-- No Duplicate Unique ID, So We Try to Check Other Column

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM PortofolioProject..NashvilleHousing
--Order by ParcelID
)

SELECT *
FROM RowNumCTE
Where row_num > 1


DELETE
FROM RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortofolioProject..NashvilleHousing

ALTER TABLE PortofolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
