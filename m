From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] lib/vsprintf.c: Add %pU - ptr to a UUID/GUID
Date: Sun, 27 Sep 2009 12:00:46 -0700
Message-ID: <1254078046.28232.183.camel@Joe-Laptop.home>
References: <cover.1254030722.git.joe@perches.com>
	 <1507728e0ea3deafa71c481d508a6e9765c92221.1254030722.git.joe@perches.com>
	 <200909271245.34000.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
To: Ingo Oeser <ioe-lkml@rameria.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752802AbZI0TAp@vger.kernel.org>
In-Reply-To: <200909271245.34000.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2009-09-27 at 12:45 +0200, Ingo Oeser wrote:
> Hi Joe,

Hello Ingo.

> On Sunday 27 September 2009, Joe Perches wrote:
> > UUID/GUIDs are somewhat common in kernel source.
> > Standardize the printed style of UUID/GUIDs by using
> > another extension to %p.
> > %pU:    01020304:0506:0708:090a:0b0c0d0e0f10
> > %pUr:   04030201:0605:0807:0a09:0b0c0d0e0f10
> Code does "01020304-0506-0708-090a-0b0c0d0e0f10".
> This is not, what commit promises. Please change the commit message!

True enough, that can change, no worries.

Does anyone have comments like:

1 what a stupid idea
2 how unnecessary
3 meh
4 bloat alert! linux is supposed to be lean
5 ok idea, bad implementation
6 sure, why not
