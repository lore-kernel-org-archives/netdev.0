From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless 2012-04-18
Date: Wed, 18 Apr 2012 15:31:58 -0400 (EDT)
Message-ID: <20120418.153158.1057856043612723800.davem@davemloft.net>
References: <20120418184320.GA2436@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120418184320.GA2436-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 18 Apr 2012 14:43:20 -0400

> First up, we have a minor signedness fix for libertas from Amitkumar
> Karwar.  Next, Arend gives us a brcm80211 fix for correctly enabling
> Tx FIFOs on channels 12 and 13.  Bing Zhao gives us some register
> address corrections for mwifiex.  Felix give us a trio of fixes --
> one for ath9k to wake the hardware properly from full sleep, one for
> mac80211 to properly handle packets in cooked monitor mode, and one
> for ensuring that the proper HT mode selection is honored.
> 
> Hauke gives us a bcma fix for handling the lack of an sprom.  Jonathon
> Bither gives us an ath5k fix for a missing THIS_MODULE build issue,
> and another ath5k fix for an io mapping leak.  Lukasz Kucharczyk
> fixes a bitwise check in cfg80211, and Sujith gives us an ath9k fix
> for assigning sequence numbers for fragmented frames.  Finally, we
> have a MAINTAINERS change from Wey-Yi Guy -- congrats to Johannes
> Berg for taking the lead on iwlwifi. :-)

:-)  Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
