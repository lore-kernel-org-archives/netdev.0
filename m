From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: zillions of lockdep whinges in
 include/net/sock.h:1408
Date: Sun, 24 Apr 2016 12:55:18 -0700
Message-ID: <1461527718.5535.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5718DA71.7050902@stressinduktion.org>
	 <20160424.143833.2292980084570149367.davem@davemloft.net>
	 <571D14F8.6070306@stressinduktion.org>
	 <20160424.145421.128023840849290353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, Valdis.Kletnieks@vt.edu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160424.145421.128023840849290353.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-04-24 at 14:54 -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Sun, 24 Apr 2016 20:48:24 +0200
> 
> > Eric's patch is worth to apply anyway, but I am not sure if it solves
> > the (fundamental) problem. I couldn't reproduce it with the exact next-
> > tag provided in the initial mail. All other reports also only happend
> > with linux-next and not net-next.
> 
> Ok, Eric please submit it formally.
> 
> Thanks!

Yes, I will first test it, and will take Hannes suggestion as well.
