From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [RFC] Revert "sierra_net: keep status interrupt URB active"
Date: Tue, 12 Nov 2013 21:29:59 +0100
Message-ID: <aeea7275-fad2-46ca-9b41-fc8a074f1714@email.android.com>
References: <1383310428-19913-1-git-send-email-bjorn@mork.no> <1383596827.29469.1.camel@dcbw.foobar.com> <1383938944.29096.7.camel@dcbw.foobar.com> <87txfm8vz5.fsf@nemi.mork.no> <1383946173.29096.12.camel@dcbw.foobar.com> <1384273510.14773.0.camel@dcbw.foobar.com> <1384277825.14773.1.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Henderson <jhen-qw6QB7/foO7QT0dZR+AlfA@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384277825.14773.1.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

>> Actually, is "[PATCH] usbnet: fix status interrupt urb handling" the
>> real fix for this problem?
>>=20
>> John, any chance you could revert my RFC patch and try Felix's patch
>in
>> that mail?
>
>It fixes the problem for me without requiring the revert or my RFC
>patch....

Yes, this looks like a reasonable explanation. Good timing.=20


Bj=C3=B8rn

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
