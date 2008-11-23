From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ROSE] zero length frame filtering in af_rose.c
Date: Sun, 23 Nov 2008 15:56:40 -0800 (PST)
Message-ID: <20081123.155640.257952451.davem@davemloft.net>
References: <200811221108.54242.bpidoux@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	ralf@linux-mips.org
To: f6bvp@amsat.org, bpidoux@free.fr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <200811221108.54242.bpidoux@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bernard Pidoux <bpidoux@free.fr>
Date: Sat, 22 Nov 2008 11:08:52 +0100

> +=A0=A0=A0=A0=A0=A0=A0}
> +
> =A0=A0=A0=A0=A0=A0=A0=A0if (copied > size) {
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0copied =3D size;
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0msg->msg_flags |=3D M=
SG_TRUNC;
> --=20

This patch, as well as your changelog message, have space
and tab characters severely corrupted by your email client.

Please fix this and resubmit.

In fact, this corruption is so severe I want you to email
this patch to yourself and try to apply it.  Do not resubmit
this until you can email the patch to yourself and apply it
cleanly.

Thank you.
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
