From: Stefan Seyfried <seife-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [patch (for 2.6.25?) 1/2] bluetooth: hci_core: defer hci_unregister_sysfs()
Date: Wed, 05 Mar 2008 10:04:51 +0100
Message-ID: <47CE6233.2040409@suse.de>
References: <200803042258.m24Mw6sO001378@imap1.linux-foundation.org> <1250A009-2EDE-4203-9472-05F68BC66001@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alon.barlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1250A009-2EDE-4203-9472-05F68BC66001-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Marcel Holtmann wrote:

> I never got a chance to test this one in a proper way, but from a =20
> logic point of view it makes sense and thus it is acked by me. I also=
 =20
> trust Stefan that he fully tested it.

It worked for me and it is in the openSUSE Factory kernels for quite a =
while
and i have no negative reports. Those kernels are still 2.6.24.1-based =
as of
now, so this testing is somewhat limited to an older kernel version :-(
--=20
Stefan Seyfried
R&D Team Mobile Devices            |              "Any ideas, John?"
SUSE LINUX Products GmbH, N=FCrnberg | "Well, surrounding them's out."

This footer brought to you by insane German lawmakers:
SUSE Linux Products GmbH, GF: Markus Rex, HRB 16746 (AG N=FCrnberg)
--
To unsubscribe from this list: send the line "unsubscribe linux-bluetoo=
th" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
