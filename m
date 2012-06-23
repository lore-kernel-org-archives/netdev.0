From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Gobi device probing
Date: Sat, 23 Jun 2012 12:44:16 +0200
Message-ID: <87lijei9z3.fsf@nemi.mork.no>
References: <87y5neidk1.fsf@nemi.mork.no>
	<20120623.023749.1066357959466872561.davem@davemloft.net>
	<87txy2ibr8.fsf@nemi.mork.no>
	<20120623.033546.563917179592608418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	H.Siebmanns-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120623.033546.563917179592608418.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (David
	Miller's message of "Sat, 23 Jun 2012 03:35:46 -0700 (PDT)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:

> From: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> Date: Sat, 23 Jun 2012 12:05:46 +0200
>
>> But failing that, would it be OK to let the 3.6 version of the fix w=
ait
>> for -rc2?  It's not a crash or any other kind of data loss bug, just=
 a
>> usability regression with a workaround.
>
> I'm shortly going to merge net into net-next as I periodically do,
> so I'm going to have to resolve the conflict regardless of how you
> finally want to fix this Gobi device probing problem.

OK.  I just sent a forward ported version for net-next.  Feel free to
use it instead of the conflicting one, or drop it if not necessary.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
