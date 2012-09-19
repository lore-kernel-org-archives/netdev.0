From: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH 2/2] Using LP firmware for taking advantage of the
 low-power capabilities.
Date: Wed, 19 Sep 2012 22:10:10 +0200
Message-ID: <CAOjsGA2uvCxnX1PH85w2vO894kZT+af-Tgj7bV-3kw3ScxN10g@mail.gmail.com>
References: <1348053493-22955-1-git-send-email-jarl@softace.dk> <1348053493-22955-2-git-send-email-jarl@softace.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
To: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	=?UTF-8?Q?G=C3=A1bor_Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1348053493-22955-2-git-send-email-jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2012/9/19 Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>:
> This is using the LP specific firmware to better take advantage of the
> Low-Power capabilities.

Gosh... I just realized that the code I introduced is completely
untested. My hardware does not reach these pieces of code...

Sorry...

However the code seems natural (due to the firmware file name pattern)
for a PHY-LP hardware, that is a bcm4313 chip (pciid 14e4:4315).

So if there is anybody with such hardware... you might want to try it... Sorry.

Jarl
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
