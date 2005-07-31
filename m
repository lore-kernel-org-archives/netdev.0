From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [git patches] new wireless stuffs
Date: Sun, 31 Jul 2005 15:04:07 +0200
Message-ID: <20050731130407.GA14550@elf.ucw.cz>
References: <42EC0C3E.7030705@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263221AbVGaNEO@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42EC0C3E.7030705@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> If this is post-2.6.13 material, that's fine.
> 
> I've been getting tired of the slow movement of wireless.  A little bit 
> of that is my fault, certainly.  I've also been wanting to get these net 
> drivers out to Linux users.
> 
> This adds HostAP, ipw2100, ipw2200, and the generic ieee80211 code.  The 
> only -changes- in this set are cosmetic.
> 
> Further work is pending from SuSE and Intel [*poke* *poke* to them], but 
> these should be working, and have been in -mm for quite a while.
> 
> One big thing I'm still hoping for is that someone will merge HostAP 
> (where ieee80211 code came from) with the ieee80211 generic code.  The 
> HostAP maintainer has been unwilling to do it, even though he has been 
> good about keeping HostAP updated, so hopefully a volunteer will step up.
> 
> Please pull from branch 'ieee80211-wifi' of
> rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> 
> to obtain the changes described by the attached diffstat/changelog.  The 
> file additions were too large to attach, so I only attached the changes 
> to existing files.  Existing drivers merely had some struct renames (for 
> new ieee80211 header), and some 'add "static" attribute' changes.

Wow, thanks!
								Pavel

-- 
if you have sharp zaurus hardware you don't need... you know my address
