From: Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Ath5k data aborts
Date: Sat, 10 Oct 2009 15:05:43 +0200
Message-ID: <m363anz9eg.fsf@intrepid.localdomain>
References: <m3tyy8fkda.fsf@intrepid.localdomain>
	<40f31dec0910100356i470a93d0x3244867e1160e9df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <40f31dec0910100356i470a93d0x3244867e1160e9df-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Nick Kossifidis's message of "Sat, 10 Oct 2009 13:56:36 +0300")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Interesting, can you provide us with an eeprom info dump from your
> card (using ath_info tool from madwifi svn) ?
> It seems we need to skip sleep clock operation in your case.

BTW the problem doesn't always happen immediately, sometimes it shows up
only on second or further hostapd invocation. I think in only occurs
while hostapd is starting - if it starts successfully, it works.
-- 
Krzysztof Halasa
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
