From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats using ethtool
Date: Sat, 17 May 2014 08:46:45 +0200
Message-ID: <87d2fcoqay.fsf@nemi.mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
	<20140516.224032.2301577488192248796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140516.224032.2301577488192248796.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Fri, 16 May 2014 22:40:32 -0400 (EDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Date: Fri, 16 May 2014 21:48:17 +0200
>
>> Quoting the previous description of this series (skip to the
>> changelog below if you only want a summary of the changes):
>
> Ok I'm fine with this, applied to net-next.

Thanks.

> Just make doubly sure that you will be ok, for a long time, with usin=
g
> the ethtool coalescing interface for configuring this because you'll
> really be stuck with this forever.

Yes, I am painfull aware of that.  So I was hoping someone would jump a=
t
this and say something like "That's not the way to do it.  Use the foo
interface instead. It's made for stuff like this".

Let's see if having it in net-next makes anyone react.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
