SELECT a.pixi_id, a.title, concat(b.first_name, ' ', b.last_name) as seller, a.start_date, c.name as category_name,
d.name as site_name
FROM `pxb_production`.`temp_listings` a,
`pxb_production`.`users` b, `pxb_production`.`categories` c, `pxb_production`.`sites` d
WHERE a.seller_id = b.id
and a.category_id = c.id
and a.site_id = d.id
and a.status = 'new';