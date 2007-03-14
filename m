From: Arkadiusz Miskiewicz <arekm@maven.pl>
Subject: Re: [ANNOUNCE] iproute2 2.6.20-070313
Date: Wed, 14 Mar 2007 12:23:48 +0100
Message-ID: <200703141223.48927.arekm@maven.pl>
References: <20070313151549.332004c9@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161142AbXCNLX6@vger.kernel.org>
In-Reply-To: <20070313151549.332004c9@freekitty>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 of March 2007, Stephen Hemminger wrote:
> This is an experimental to the iproute2 command set.
>
> The version number includes the kernel version to denote what feature=
s are
> supported. The same source should build on older systems, but obvious=
ly the
> newer kernel features won't be available. As much as possible, this p=
ackage
> tries to be source compatible across releases.
>
> It can be downloaded from:
> =20
> http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.20-07031=
3.tar.
>gz

This patch

http://www.mail-archive.com/netdev@vger.kernel.org/msg27506.html

didn't make into upstream linux kernel it seems.

The question is - are patches adding some functionality that's not in u=
pstream=20
kernel accepted?

There is one wrr patch for iproute floating around that I'm thinking ab=
out.

--=20
Arkadiusz Mi=B6kiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
