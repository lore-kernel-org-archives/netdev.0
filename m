From: bert hubert <ahu@ds9a.nl>
Subject: Re: netdev-2.6 queue updated
Date: Wed, 23 Mar 2005 08:55:25 +0100
Message-ID: <20050323075525.GA25273@outpost.ds9a.nl>
References: <4240E35C.2090203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>,
        "akpm @ osdl. org Linux Kernel" <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4240E35C.2090203@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 22, 2005 at 10:32:44PM -0500, Jeff Garzik wrote:
> Wireless update, and various minor fixes.
> 
> BK URL, patch URL, and changelog attached.

Jeff, akpm can you predict if this will make 2.6.12? Especially the wireless
& hostap stuff.

>  net/ieee80211/Kconfig                           |   67 
>  net/ieee80211/Makefile                          |   11 
>  net/ieee80211/ieee80211_crypt.c                 |  259 +
>  net/ieee80211/ieee80211_crypt_ccmp.c            |  470 ++
>  net/ieee80211/ieee80211_crypt_tkip.c            |  708 ++++
>  net/ieee80211/ieee80211_crypt_wep.c             |  272 +
>  net/ieee80211/ieee80211_module.c                |  268 +
>  net/ieee80211/ieee80211_rx.c                    | 1206 +++++++
>  net/ieee80211/ieee80211_tx.c                    |  448 ++
>  net/ieee80211/ieee80211_wx.c                    |  471 ++


-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
