select *
from portfolioproject..nashville_housing_data
---------------------------------------------------------
--converted data

select [SaleDate]
from portfolioproject..nashville_housing_data

select CAST([SaleDate] as date) as converted_date
from portfolioproject..nashville_housing_data

alter table nashville_housing_data
add converted_date date;

update nashville_housing_data
set converted_date = CAST([SaleDate] as date)

select converted_date
from portfolioproject..nashville_housing_data
-----------------------------------------------------------------------------------------
--clean null property address data
select first_data.ParcelID, first_data.PropertyAddress, second_data.PropertyAddress, ISNULL(second_data.PropertyAddress, first_data.PropertyAddress)
from portfolioproject..nashville_housing_data first_data
join portfolioproject..nashville_housing_data second_data
on first_data.[ParcelID] = second_data.[ParcelID]
and first_data.[UniqueID ] <> second_data.[UniqueID ]
where second_data.PropertyAddress is null

update second_data
set [PropertyAddress] = ISNULL(second_data.PropertyAddress, first_data.PropertyAddress)
from portfolioproject..nashville_housing_data first_data
join portfolioproject..nashville_housing_data second_data
on first_data.[ParcelID] = second_data.[ParcelID]
and first_data.[UniqueID ] <> second_data.[UniqueID ]
where second_data.PropertyAddress is null
--------------------------------------------------------------------------------------------
--replacing null in ownername column with no name
update nashville_housing_data
set [OwnerName] = 'no name'
where [OwnerName] is null
---------------------------------------------------------------------------------------------
--split property address to address and cities
select [PropertyAddress]
from portfolioproject..nashville_housing_data

select SUBSTRING ([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress]) - 1) as Address,
SUBSTRING ([PropertyAddress], CHARINDEX(',', [PropertyAddress]) + 1, LEN([PropertyAddress])) as City
from portfolioproject..nashville_housing_data

alter table nashville_housing_data
add property_split_address nvarchar(255)

update nashville_housing_data
set property_split_address = SUBSTRING ([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress]) - 1)

alter table nashville_housing_data
add property_split_city nvarchar(255)

update nashville_housing_data
set property_split_city = SUBSTRING ([PropertyAddress], CHARINDEX(',', [PropertyAddress]) + 1, LEN([PropertyAddress]))

select [OwnerAddress]
from portfolioproject..nashville_housing_data

select PARSENAME(replace([OwnerAddress], ',', '.'), 3) as owner_split_address,
PARSENAME(replace([OwnerAddress], ',', '.'), 2) as owner_split_city,
PARSENAME(replace([OwnerAddress], ',', '.'), 1) as owner_split_state
from portfolioproject..nashville_housing_data

alter table nashville_housing_data
add owner_split_address nvarchar(255)

update nashville_housing_data
set owner_split_address = PARSENAME(replace([OwnerAddress], ',', '.'), 3)

alter table nashville_housing_data
add owner_split_city nvarchar(255)

update nashville_housing_data
set owner_split_city = PARSENAME(replace([OwnerAddress], ',', '.'), 2)

alter table nashville_housing_data
add owner_split_state nvarchar(255)

update nashville_housing_data
set owner_split_state = PARSENAME(replace([OwnerAddress], ',', '.'), 1)
-------------------------------------------------------------------------------------------------
--clean the sold as vacant, where y put yes and where n put no 
select distinct([SoldAsVacant]), COUNT([SoldAsVacant])
from portfolioproject..nashville_housing_data
group by [SoldAsVacant]
order by COUNT([SoldAsVacant]) desc

select case when [SoldAsVacant] = 'y' then 'yes'
            when [SoldAsVacant] = 'n' then 'no'
			else [SoldAsVacant]
			end,
COUNT([SoldAsVacant])
from portfolioproject..nashville_housing_data
group by [SoldAsVacant]
order by COUNT([SoldAsVacant]) desc

update nashville_housing_data
set [SoldAsVacant] =  case when [SoldAsVacant] = 'y' then 'yes'
            when [SoldAsVacant] = 'n' then 'no'
			else [SoldAsVacant]
			end
----------------------------------------------------------------------------------------
--revoming of duplicate data in specific columns

--with rownumcte as(
--select *, ROW_NUMBER() over ( partition by [ParcelId], [PropertyAddress], [SalePrice], [SaleDate], [LegalReference]
--order by UniqueId) row_num
--from portfolioproject..nashville_housing_data
--) select *
--from rownumcte
--where row_num > 1
--order by [PropertyAddress]

with rownumcte as(
select *, ROW_NUMBER() over ( partition by [ParcelId], [PropertyAddress], [SalePrice], [SaleDate], [LegalReference]
order by UniqueId) row_num
from portfolioproject..nashville_housing_data
) delete
from rownumcte
where row_num > 1
------------------------------------------------------------------------------------------------------------------------------
-- deleting other unused columns to make the data set more appealing
alter table nashville_housing_data
drop column [OwnerAddress], [propertyAddress]

select *
from portfolioproject..nashville_housing_data
























