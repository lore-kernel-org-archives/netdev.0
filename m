From: Danial Thom <danial_thom@yahoo.com>
Subject: Re: 2.6.12 Performance problems
Date: Sat, 27 Aug 2005 07:35:16 -0700 (PDT)
Message-ID: <20050827143517.19566.qmail@web33312.mail.mud.yahoo.com>
References: <20050827111904.GA6484@tentacle.sectorb.msk.ru>
Reply-To: danial_thom@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Ben Greear <greearb@candelatech.com>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965182AbVH0OfT@vger.kernel.org>
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
In-Reply-To: <20050827111904.GA6484@tentacle.sectorb.msk.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- "Vladimir B. Savkin" <master@sectorb.msk.ru>
wrote:

> On Wed, Aug 24, 2005 at 11:08:43PM -0700,
> Danial Thom wrote:
> > If your test is still set up, try compiling
> > something large while doing the test. The
> drops
> > go through the roof in my tests.
> > 
> Couldn't this happen because ksoftirqd by
> default 
> has a nice value of 19?
> 
> ~
> :wq
>                                         With
> best regards, 
>                                           
> Vladimir Savkin. 

renicing ksoftirqd improves it a bit, but
still tons of loss, even at only 120Kpps.


Danial


		
____________________________________________________
Start your day with Yahoo! - make it your home page 
http://www.yahoo.com/r/hs 
 
