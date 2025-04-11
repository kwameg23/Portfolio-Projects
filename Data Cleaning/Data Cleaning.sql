
--CLEANING DATA

SELECT*
FROM PortfolioProject2..NashvilleHousing

-- STANDARDIZE DATE FORMAT

SELECT SaleDate
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date , SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject2..NashvilleHousing

--------------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHousing


SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHousing
WHERE PropertyAddress is null


SELECT *
FROM PortfolioProject2..NashvilleHousing
WHERE PropertyAddress is null


SELECT *
FROM PortfolioProject2..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHousing



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 


FROM PortfolioProject2..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

SELECT OwnerAddress
FROM PortfolioProject2..NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y to YES and N to No in "SoldAsVacant"

SELECT Distinct(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2





SELECT SoldAsVacant ,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject2..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num

FROM PortfolioProject2..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS


SELECT*
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate