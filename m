From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN card
Date: Wed, 01 May 2013 20:33:10 +0200
Message-ID: <87r4hqbleh.fsf@nemi.mork.no>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matthias Urlichs <smurf-ci3XGGwdvIcvfNposrsB4g@public.gmane.org>, dagofthedofg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1367431305.12353.8.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's
	message of "Wed, 01 May 2013 13:01:45 -0500")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> A rebranded Novatel E371 for AT&T's LTE bands.

I don't think we're handling the Novatel branded E371 yet?  I tried
googling for ID of that, but were unable to find it.  I guess you don't
know either...  Well, nothing we can do about that until someone report=
s
it.

=46or the qmi_wwan part:
Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>


> diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/option.=
c
> index 558adfc..569caf6 100644
> --- a/drivers/usb/serial/option.c
> +++ b/drivers/usb/serial/option.c

Combining net and usb patches in the same commit is probably not wise?



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
