From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25: unsigned cannot be less than 0 in
 ax25_ctl_ioctl()
Date: Thu, 29 Oct 2009 23:06:53 -0700 (PDT)
Message-ID: <20091029.230653.256114041.davem@davemloft.net>
References: <4AD37D44.9050207@gmail.com>
	<4AD3A67B.6070703@cerebellum.kd>
	<4AD5EDA6.4040709@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevind@esi.com.au, wharms@bfs.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, jreuter@yaina.de, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4AD5EDA6.4040709@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <roel.kluin@gmail.com>
Date: Wed, 14 Oct 2009 17:26:30 +0200

> struct ax25_ctl_struct member `arg' is unsigned and cannot be less
> than 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied to net-next-2.6
