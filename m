From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V6 2/2] net/mlx4_en: Use affinity hint
Date: Mon, 02 Jun 2014 00:10:53 -0700 (PDT)
Message-ID: <20140602.001053.1333842492033184886.davem@davemloft.net>
References: <1401683831.3645.169.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140601.215650.2131746246978305213.davem@davemloft.net>
	<1401685992.3645.173.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, ogerlitz@mellanox.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, yuvala@mellanox.com,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401685992.3645.173.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 01 Jun 2014 22:13:12 -0700

> On Sun, 2014-06-01 at 21:56 -0700, David Miller wrote:
> 
>> Indeed you have to provide a dummy version for a non-SMP build etc.
>> 
>> I'm reverting.
>> 
> 
> Hi David. I think your revert took one wrong commit.

Thanks I'll fix it up.
