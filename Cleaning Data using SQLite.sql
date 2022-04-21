--Data Cleaning Queries

select * from HousingData;

-- Standardise Date  Format

select SaleDate from HousingData;

--Populate Property Address Data

select * from HousingData
where PropertyAddress='';

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress) 
from HousingData as a
Join HousingData as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
;


Update HousingData
Set PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
from HousingData a
Join HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
;

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from HousingData;

select PropertyAddress, substr(PropertyAddress, 1, instr(PropertyAddress, ',')-1) as Address,
substr(PropertyAddress, instr(PropertyAddress, ',')+1, length(PropertyAddress)) as City
from HousingData; 

Alter Table HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData
Set PropertySplitAddress = substr(PropertyAddress, 1, instr(PropertyAddress, ',')-1);

Alter Table HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData
Set PropertySplitCity = substr(PropertyAddress, instr(PropertyAddress, ',')+1, length(PropertyAddress));

--Owner Address

select OwnerAddress, substr(OwnerAddress, 1, instr(OwnerAddress, ',')-1) as OwnerAddress,
substr(OwnerAddress, (instr(OwnerAddress, ',')+1), instr(substr(OwnerAddress,instr(OwnerAddress, ',')+1), ',')-1) as OwnerCity,
substr(OwnerAddress, (instr(OwnerAddress, ',') + instr(substr(OwnerAddress, instr(OwnerAddress, ',')+1), ',' ) +1)) as OwnerState
from HousingData; 



Alter Table HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
Set OwnerSplitAddress = substr(OwnerAddress, 1, instr(OwnerAddress, ',')-1);

Alter Table HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
Set OwnerSplitCity = substr(OwnerAddress, (instr(OwnerAddress, ',')+1), instr(substr(OwnerAddress,instr(OwnerAddress, ',')+1), ',')-1);

Alter Table HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
Set OwnerSplitState = substr(OwnerAddress, (instr(OwnerAddress, ',') + instr(substr(OwnerAddress, instr(OwnerAddress, ',')+1), ',' ) +1));

select * from HousingData;

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant) as cnt
from HousingData
group by SoldAsVacant
order by cnt desc
;

Select SoldAsVacant,
Case when SoldAsVacant ='Y' Then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    Else SoldAsVacant
    END as Modified_Data
from HousingData;

Update HousingData
set SoldAsVacant = Case when SoldAsVacant ='Y' Then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    Else SoldAsVacant
    END
;

-- Removing Duplicates

With RowNumCTE as(
select * ,
row_number() over(
partition by ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            Order by "UniqueID "
) row_num
from HousingData)

Delete
from RowNumCTE
where row_num > 1;


-- Delete Unsued Columns

select * from HousingData;

Alter Table HousingData
Drop column PropertyAddress;




