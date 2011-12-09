From: Nico Schottelius <nico-linux-20111201@schottelius.org>
Subject: Re: BCM43224 hanging [3.2.0-rc4-00248-gb835c0f]
Date: Fri, 9 Dec 2011 19:00:05 +0100
Message-ID: <20111209180005.GA5055@ethz.ch>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com>
 <20111202150128.GC3096@schottelius.org>
 <20111207190821.GA1775@schottelius.org>
 <4EE0F50B.5040407@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nico Schottelius <nico-linux-20111201@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, Greg KH <gregkh@suse.de>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4EE0F50B.5040407@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Arend,

Arend van Spriel [Thu, Dec 08, 2011 at 06:34:03PM +0100]:
> On 12/07/2011 08:08 PM, Nico Schottelius wrote:
> Could you try and see what happens when you kill wpa_supplicant.

I can't kill it, it's in D state :-/

I was just browsing through
drivers/net/wireless/brcm80211/brcmsmac/main.c and it seems that
your patch from my last problem has already been applied.

What may be different this time that the network being used
is *not* on 5Ghz, but 2.4 Ghz (I'm not in the same environment anymore).

Nico

-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
