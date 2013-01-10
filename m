From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-01-09
Date: Thu, 10 Jan 2013 00:12:01 -0800 (PST)
Message-ID: <20130110.001201.1186658910482812389.davem@davemloft.net>
References: <20130109191817.GA17321@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130109191817.GA17321@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 9 Jan 2013 14:18:18 -0500

> Included is a mac80211 pull, of which Johannes says the following:
> 
> 'This includes a number of fixes for various pieces of mac80211. I've
> also included Thomas's memory RMC hash table optimisation since it
> saves so much memory.'
> 
> Also from Johannes is an iwlwifi pull:
> 
> 'I have two fixes for iwlwifi: one to fix a lost return value that was
> dropped in a previous patch and could cause "nobody cared" IRQ messages,
> and one to work around a firmware issue.'
> 
> Amitkumar Karwar brings an mwifiex for a typo in an comparison.
> 
> Bing Zhao gives us an mwifiex fix to properly check the return value
> from wait_event_interruptible and handle it properly.
> 
> Chen Gang provides a fix to make iwlegacy use strlcpy instead of
> strncpy, avoiding a potential buffer underflow.
> 
> Julian Wollrath fixes a typo in an error message in rtlwifi.
> 
> Larry Finger brings a b43 fix for a firmware loading problem.
> 
> Nickolai Zeldovich avoids a use-after-free in the mwl8k driver.
> 
> Vladimir Kondratiev brings the last big piece, the new Qualcomm/Atheros
> wil6210 802.11ad driver.  Since it is for new hardware, I hope that
> taking it for 3.8 is not a problem.
> 
> Please let me know if there are problems!

Pulled, thanks John.
