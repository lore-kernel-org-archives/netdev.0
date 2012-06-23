From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Gobi device probing
Date: Sat, 23 Jun 2012 02:37:49 -0700 (PDT)
Message-ID: <20120623.023749.1066357959466872561.davem@davemloft.net>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
	<20120622.171735.637204872051168180.davem@davemloft.net>
	<87y5neidk1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	H.Siebmanns-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y5neidk1.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Sat, 23 Jun 2012 11:26:54 +0200

> Is waiting for 3.6-rc1 the best alternative, or is cherry-picking the=
m
> an option?

I'm extremely reluctant to have a dependency on another tree.

The USB tree, on the other hand, could pull the net-next tree
in so you can continue your dependent work there.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
