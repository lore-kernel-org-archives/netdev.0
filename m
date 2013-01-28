From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: iwlegacy: remove unused variable
Date: Mon, 28 Jan 2013 10:56:41 +0100
Message-ID: <20130128095640.GA2316@redhat.com>
References: <1359312941-30661-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1359312941-30661-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 27, 2013 at 10:55:41AM -0800, Guenter Roeck wrote:
> drivers/net/wireless/iwlegacy/4965.c: In function =E2=80=98il4965_pos=
t_associate=E2=80=99:
> drivers/net/wireless/iwlegacy/4965.c:1751:25: warning: variable =E2=80=
=98conf=E2=80=99 set but
> not used [-Wunused-but-set-variable]
>=20
> seen when building allmodconfig on x86_64 with W=3D1 by removing the =
unused
> variable.
>=20
> Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>

ACK
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
