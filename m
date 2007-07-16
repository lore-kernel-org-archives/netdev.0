From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Mon, 16 Jul 2007 17:59:20 -0400
Message-ID: <469BEA38.2040804@garzik.org>
References: <20070710185758.GH7927@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070710185758.GH7927-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 71780f59e127bb281a9302d430495ca9586c14e7:
>   Linus Torvalds (1):
>         Merge branch 'for-linus' of git://git.kernel.org/.../ieee1394/linux1394-2.6
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik
> 
> Adrian Bunk (1):
>       drivers/net/wireless/libertas/wext.c: remove dead code
> 
> Dan Williams (1):
>       libertas: fix disabling WPA
> 
> Daniel Drake (4):
>       zd1211rw: Allow channels 1-11 for unrecognised regulatory domains
>       zd1211rw: Detect more AL2230S radios
>       zd1211rw: Add ID for Buffalo WLI-U2-KG54L
>       zd1211rw: Defer firmware load until first ifup
> 
> Holger Schurig (1):
>       libertas: fix use-after-free in rx path
> 
> Jean Tourrilhes (1):
>       softmac: Fix ESSID problem
> 
> Matthias Kaehlcke (1):
>       use list_for_each_entry() for iteration in Prism 54 driver
> 
> Michael Wu (1):
>       rtl8187: fix endianness issue in rtl8225 register writing
> 
> Michal Schmidt (5):
>       airo: disable the PCI device when unloading module
>       airo: delay some initialization until the netdev is up
>       airo: fix a race causing initialization failures
>       airo: simpler calling convention for enable_MAC()
>       airo: start with radio off
> 
> Robert P. J. Day (1):
>       WIRELESS: Remove clearly obsolete libertas/version.h file.
> 
> Stephen Hemminger (2):
>       ipw2200: rf kill switch polling power saving
>       ipw2100: RF kill switch timer power save

pulled
