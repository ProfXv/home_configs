import configparser, argparse
from spark import main


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Whether prompting.')
    parser.add_argument('-p', '--prompt', action='store_true')
    parser.add_argument('-m', '--material', default='')
    args = parser.parse_args()

    config = configparser.ConfigParser()
    config.read('.service/config.ini')
    defaults = config['spark']

    if args.prompt:
        print('Your question is:')
        question = input()
        print(64*'=')
        main(**defaults,query=question+'\n你回答问题所基于的材料如下：'+args.material)
    else:
        main(**defaults,query=args.material)
