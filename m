From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 20:06:02 -0300
Message-ID: <20100921230601.GB32090@khazad-dum.debian.net>
References: <20100921162657.GA22183@khazad-dum.debian.net>
 <1285086679.2617.672.camel@edumazet-laptop>
 <20100921180940.GA8754@khazad-dum.debian.net>
 <20100921.122406.193718558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, nbowler@elliptictech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jarkao2@gmail.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100921.122406.193718558.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2010, David Miller wrote:
> > Since there wasn't one, and I didn't readly find any post in this thread
> > that mentioned it should also go to stable, AND it looked at first glance
> > like something that should go to stable, I asked about it.
> 
> Sorry, that is not how we typically handle things in the networking.
> 
> I queue up all appropriate -stable patches automatically.

I see.

>    I want fixes to sit and cook in Linus's tree for a while before
>    they go to -stable unless it's an _incredibly_ obvious fix.
>    This allows any bugs in the fix to be shaken out first.

...

> All of the rest should be carefully queued up for -stable and
> submitted there after a week or two of the patch sitting in Linus's
> tree.

That is a very good way of doing things.  Thanks for the hard work!

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
