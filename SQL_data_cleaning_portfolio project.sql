--DATA CLEANING

Select *
From NashvilleHousing
---------------------------------------------------------------------------------
--Promjena formata datuma

Select SaleDate, CONVERT(Date, SaleDate)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------
--Popunjavanje podataka o adresi nekretnine

Select PropertyAddress
From NashvilleHousing
Where PropertyAddress is Null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------
--Razdvajanje adrese na pojedinačne stupce (Adresa, Grad, Država)

Select PropertyAddress
From NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Town
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

----------------------------------------------------------------------------------
--Promjena Y i N u "Yes" i "No" u stupcu "Sold as Vacant"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

----------------------------------------------------------------------------------
--Uklanjanje dupliciranih zapisa

WITH RowNumCTE AS( 
Select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

From NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

-----------------------------------------------------------------------------------
--Brisanje nepotrebnih stupaca

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
FROM NashvilleHousing