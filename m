From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] net: qmi_wwan: fix Cinterion PLXX product ID
Date: Wed, 25 Sep 2013 18:10:13 +0200
Message-ID: <87y56kopay.fsf@nemi.mork.no>
References: <1380121356-28601-1-git-send-email-aleksander@lanedo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Hans-Christoph Schemmel <hans-christoph.schemmel-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>,
	Christian Schmiedl <christian.schmiedl-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>,
	Nicolaus Colberg <nicolaus.colberg-av01+Y74gORBDgjK7y7TUQ@public.gmane.org>
To: Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1380121356-28601-1-git-send-email-aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org>
	(Aleksander Morgado's message of "Wed, 25 Sep 2013 17:02:36 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Aleksander Morgado <aleksander-bhGbAngMcJvQT0dZR+AlfA@public.gmane.org> writes:

> Cinterion PLXX LTE devices have a 0x0060 product ID, not 0x12d1.
>
> The blacklisting in the serial/option driver does actually use the co=
rrect PID,
> as per commit 8ff10bdb14a52e3f25d4ce09e0582a8684c1a6db ('USB: Blackli=
sted
> Cinterion's PLxx WWAN Interface').

Right.  This seems like a typo.  Thanks

Acked-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
