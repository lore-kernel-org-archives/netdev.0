From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Thu, 29 Mar 2012 02:51:06 -0400 (EDT)
Message-ID: <20120329.025106.1572220523319138513.davem@davemloft.net>
References: <1332853442.3248.15.camel@edumazet-laptop>
	<20120327.225109.752822925052179338.davem@davemloft.net>
	<1377643.vUarymgFD1@hector>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org
To: remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1377643.vUarymgFD1@hector>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: R=E9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Date: Thu, 29 Mar 2012 09:30:32 +0300

> I guess I should use my personal email instead...

nokia.com tends to eat 2 out of every 3 mailing list postings
on vger.kernel.org, so yes I'd say using person email would
be a good idea
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
