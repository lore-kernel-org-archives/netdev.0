From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Fri, 14 Mar 2014 09:34:39 +0100
Message-ID: <87wqfxnppc.fsf@nemi.mork.no>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
	<20140313202557.GV3200@reaktio.net>
	<1394746907.15946.8.camel@dcbw.local>
	<20140313220812.GW3200@reaktio.net>
	<20140314075548.GX3200@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140314075548.GX3200-GxtO3QLqHcLR7s880joybQ@public.gmane.org> ("Pasi =?utf-8?Q?K=C3=A4r?=
 =?utf-8?Q?kk=C3=A4inen=22's?= message
	of "Fri, 14 Mar 2014 09:55:48 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pasi K=C3=A4rkk=C3=A4inen <pasik-X3B1VOXEql0@public.gmane.org> writes:
> On Fri, Mar 14, 2014 at 12:08:12AM +0200, Pasi K=C3=A4rkk=C3=A4inen w=
rote:
>>
>> I've been using:
>>=20
>> ATQ0 V1 E1 S0=3D0
>> AT^NDISDUP=3D1,1,"internet"
>> AT^DHCP?
>>
>
> Oh, I forgot to mention.. after I send AT^NDISDUP=3D1,1,"internet" I =
get this:
>
> ^NDISSTAT:1,,,"IPV4"
>
> .. which to my understanding means it's connected (1=3D=3Dconnected).
> Also sending AT^NDISSTATQRY? results in:
>
> ^NDISSTATQRY: 1,,,"IPV4"


What response do you get to the AT^DHCP? request when connected?



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
