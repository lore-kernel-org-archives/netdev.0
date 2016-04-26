From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Tue, 26 Apr 2016 17:49:13 +0200
Message-ID: <23978128.X7F5UHGaYZ@wuerfel>
References: <1461590139-1396745-1-git-send-email-arnd@arndb.de> <5940636.9Nic57IXcZ@wuerfel> <CALzJLG-d1mTs9SdubELzQtczsiVY0cgzBc3BC6wJoBgx4Wg_+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>,
	Tariq Toukan <tariqt@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALzJLG-d1mTs9SdubELzQtczsiVY0cgzBc3BC6wJoBgx4Wg_+Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 April 2016 17:41:45 Saeed Mahameed wrote:
> On Tue, Apr 26, 2016 at 4:53 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > Sure, do you want to just edit this when you forward the patch, or
> > do you need me to do it?
> >
> 
> Well, I won't say no if you want to do it 
> 

All I want is to get rid of the patch in my queue. I guess it's
worth the 10 minute of work ;-)

v2 coming

	Arnd
