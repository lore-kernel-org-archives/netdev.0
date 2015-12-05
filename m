From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net,stable] net: cdc_mbim: add "NDP to end" quirk for
 Huawei E3372
Date: Sat, 5 Dec 2015 23:47:07 +0100 (CET)
Message-ID: <alpine.LNX.2.20.1512052343321.14118@localhost.localdomain>
References: <1449316910-8009-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sami Farin <hvtaifwkbgefbaei-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449316910-8009-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello guys.
I am sorry the way my feature is actually implemented is limiting MUX 
performances in mbim case, even with good devices. When I developed it, I also 
probably tought this wasn't affecting MBIM devices.

Thank you Bjorn, great work in handling it.
Thank you for all of you; Thank you for reporting this Sami.

Acked-By: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
