From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH net-next] asix: asix_rx_fixup surgery to reduce skb
 truesizes
Date: Tue, 20 Mar 2012 07:28:46 -0700
Message-ID: <1332253726.7893.5.camel@edumazet-glaptop>
References: <1331792312.2543.16.camel@edumazet-laptop>
	 <CANEJEGtndncj1biMZSBC1rt36a66iWGp7wU_OxCxpA_PVBGZqA@mail.gmail.com>
	 <001501cd06a3$d08fe6e0$71afb4a0$@com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Grant Grundler' <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	'Greg Kroah-Hartman' <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	'David Miller' <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'netdev' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	'Aurelien Jacobs' <aurel-U/apLSaFET4dnm+yROfE0A@public.gmane.org>,
	'Trond Wuellner' <trond-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	'Paul Stewart' <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: allan <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <001501cd06a3$d08fe6e0$71afb4a0$@com.tw>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-03-20 at 22:14 +0800, allan wrote:
> Dear All,
> 
> Resend this email due to illegal attachment in my previous email. Please let me know if you need to get the attachment. Thanks a lot.

Thanks a lot for testing Allan


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
