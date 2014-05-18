From: Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
	using ethtool
Date: Sun, 18 May 2014 03:19:17 +0200
Message-ID: <20140518011917.11270.qmail@stuge.se>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no> <20140516.224032.2301577488192248796.davem@davemloft.net> <87d2fcoqay.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87d2fcoqay.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bj=C3=B8rn Mork wrote:
> > Just make doubly sure that you will be ok, for a long time, with us=
ing
> > the ethtool coalescing interface for configuring this because you'l=
l
> > really be stuck with this forever.
>=20
> Yes, I am painfull aware of that.  So I was hoping someone would jump=
 at
> this and say something like "That's not the way to do it.  Use the fo=
o
> interface instead. It's made for stuff like this".

sysfs?


//Peter
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
