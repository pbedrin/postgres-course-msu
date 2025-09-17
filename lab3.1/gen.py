from dataclasses import replace
from random import randint, sample, choice, random, uniform
from datetime import datetime, timedelta
from tqdm import tqdm
from faker import Faker
import datetime
import json


N = 100
path_usr = '/Library/PostgreSQL/11/bin/Database/users1.csv'
path_int = '/Library/PostgreSQL/11/bin/Database/interactions1.csv'
path_art = '/Library/PostgreSQL/11/bin/Database/artworks1.csv'
path_loc = '/Library/PostgreSQL/11/bin/Database/locations1.csv'
path_weeks = '/Library/PostgreSQL/11/bin/Database/weeks1.csv'

LOC_COUNT = 900
USR_COUNT = 100
# ARTS_COUNT = 1000
# INTER_ADD = 100

obj = Faker(['ru_RU', 'en_GB'])

with open(path_loc, 'w') as locations:
    with open(path_art, 'w') as artworks:
        with open(path_int, 'w') as interactions:
            with open(path_usr, 'w') as users:
                with open(path_weeks, 'w') as weeks:
                    st_day = datetime.date(year=2021, month=1, day=1)
                    loc_types = ['музей', 'частная коллекция', 'строение', 'библиотека', 'вуз', 'склад', 'магазин', 'аукционный дом', 'под открытым небом', 'другое']
                    currency_lst = ['RUB', 'USD', 'EUR', 'CNY']
                    art_areas = ['вазопись', 'живопись', 'скульптура', 'архитектура', 'граффити', 'фотоискусство', 'комикс', 'графика', 'декоративно-прикладное искусство', 'гравюра']
                    styles = ['сюрреализм', 'экспрессионизм', 'символизм', 'краснофигурный стиль', 'реализм', 'ренессанс', 'тромплёй', 'социалистический реализм', 'модерн', 'неоготика', 'деконструктивизм', 'малая пластика', 'минималистика', 'фентези', 'романтизм']
                    measures = ['cm', 'm', 'mm']
                    newl = '\n'
                    newr = '\r'
                    artwork_id = 1
                    inter_id = 1

                    week_id = 1
                    for month in range(1, 6):
                        for week in range(1, 6):
                            weeks.write(
                                f'{week_id}|'
                                '2021|'
                                f'{month}|'
                                f'{week}\n'
                            )
                            week_id += 1

                    for user_id in range(1, USR_COUNT + 1):
                        users.write(
                            f'{user_id}|'
                            f'{obj.first_name()}|'
                            f'{obj.msisdn()}|'
                            f'{obj.email()}\n'
                        )

                    sum_a_range = 0
                    for location_id in range(1, LOC_COUNT + 1):
                        contacts = '{"address":"' + obj.address().replace('\n', ' ') + '", "mail":"' + obj.email() + '"}'
                        location_name = obj.company()
                        locations.write(f'{location_id}|{location_name}|{choice(loc_types)}|{contacts}\n')
                        
                        if location_id != LOC_COUNT:
                            a_range = randint(LOC_COUNT + 100, LOC_COUNT+400)
                            sum_a_range += a_range
                        elif sum_a_range < 1000000:
                            a_range = 1000000 - sum_a_range
                        else:
                            a_range = 3
                        print(f'LocID: {location_id}. Sum_AW: {sum_a_range}')
                        for i in range(a_range):
                            size = '{"width": ' + str(randint(1,500)) + ', "height": ' + str(randint(1,500)) + ', "length": ' + str(randint(1,500)) + ', "measure": "' + choice(measures) + '"}'
                            title = obj.sentence(nb_words=randint(1,3))[:-1]
                            authors = str(set([obj.name() for i in range(randint(1,2))])).replace("'", "")
                            style = choice(styles)
                            area = choice(art_areas)
                            tag = str(set(obj.words(nb=randint(1,6)))).replace("'", "")
                            artworks.write(f'{artwork_id}|{title}|'
                                f'{authors}|'
                                f'{obj.text(max_nb_chars=randint(50,250)).replace(newl, "")}|'
                                f'{randint(-520, 2022)}|'
                                f'{obj.image_url()}|'
                                f'{randint(500, 35000000)}.00|'
                                f'{choice(currency_lst)}|'
                                f'{area}|'
                                f'{style}|'
                                f'{location_id}|'
                                f'{location_name}|'
                                f'{size}|'
                                f'{tag}|'
                                f'{choice(["null", round(uniform(1.0, 5.0), 1)])}\n')
            
                            for w in range(1, week_id):
                                random_users_len = user_id
                                INTER_ADD = 4
                                random_users = sample([i for i in range(1, user_id + 1)], INTER_ADD)
                                for j in range(1, INTER_ADD + 1):
                                    curr_user_id = random_users[j-1]
                                    views = randint(0, 10)
                                    if views != 0:
                                        duration = f'0:{randint(0,59)}:{randint(0,59)}'
                                    else:
                                        duration = '0:0:0'

                                    interactions.write(f'{inter_id}|'
                                        f'{w}|'
                                        f'{artwork_id}|'
                                        f'{curr_user_id}|'
                                        f'{obj.city()}|'
                                        f'{views}|'
                                        f'{duration}|'
                                        f'{choice(["null", randint(1, 5)])}|'
                                        f'{choice([0, 1])}\n'
                                    )
                                    inter_id += 1
                            artwork_id += 1