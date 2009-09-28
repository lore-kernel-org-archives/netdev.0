From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.31-git17] WARNING: at kernel/hrtimer.c:648 hres_timers_resume+0x40/0x50()/WARNING: at drivers/base/sys.c:353 __sysdev_resume+0xc3/0xe0()
Date: Mon, 28 Sep 2009 23:13:15 +0200
Message-ID: <200909282313.15246.rjw@sisk.pl>
References: <8db1092f0909270105x4b49daf8k268e453d2379020c@mail.gmail.com> <8db1092f0909281138t18a379d1qdf999b0610ed6414@mail.gmail.com> <8db1092f0909281308s36c35c80s65c18dcbcf9fff2b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Yong Zhang <yong.zhang0@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	clemens@ladisch.de, venkatesh.pallipadi@intel.com, gregkh@suse.de,
	zambrano@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Maciej Rutecki <maciej.rutecki@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753334AbZI1VMJ@vger.kernel.org>
In-Reply-To: <8db1092f0909281308s36c35c80s65c18dcbcf9fff2b@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 28 September 2009, Maciej Rutecki wrote:
> 2009/9/28 Maciej Rutecki <maciej.rutecki@gmail.com>:
> >
> > Add patch and remove previous:
> > http://unixy.pl/maciek/download/kernel/2.6.31-git17/gumis/dmesg-debug.txt
> >
> > s2disk&resume twice.
> >
> > no "timekeeping_resume() called with IRQs enabled!".
> >
> > I found some interesting thing, warnings appear only once, during
> > first s2disk, on second don't appear.
> 
> Already I test 2.6-32-rc1 few times; warnings has gone. Any patches
> has been add since 2.6.31-git17?

Quite some of them, actually.

Thanks,
Rafael
