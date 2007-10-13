From: Ismail =?utf-8?q?D=C3=B6nmez?= <ismail@pardus.org.tr>
Subject: Re: Bluetooth wireless mouse very sluggish when there is moderate network activity
Date: Sat, 13 Oct 2007 17:15:25 +0300
Message-ID: <200710131715.25193.ismail@pardus.org.tr>
References: <200710131713.03345.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:41071 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754276AbXJMOPL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 10:15:11 -0400
In-Reply-To: <200710131713.03345.ismail@pardus.org.tr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/moderated/moderate of course :-/

Saturday 13 October 2007 Tarihinde 17:13:03 yazm=C4=B1=C5=9Ft=C4=B1n=C4=
=B1z:
> Hi all,
>
> I got a Bluetooth wireless mouse identifed as,
>
> input: Microsoft Microsoft=EF=BF=BD Wireless Notebook Presenter Mouse=
 8000
> as /devices/pci0000:00/0000:00:1d.1/usb3/3-1/3-1.3/3-1.3:1.0/input/in=
put12
> input: USB HID v1.11 Mouse [Microsoft Microsoft=EF=BF=BD Wireless Not=
ebook
> Presenter Mouse 8000] on usb-0000:00:1d.1-1.3
>
> Problem is when there is a moderate traffic on wireless interface
> (300-400k/s down 50-60k/up on 4Mbit) mouse is really sluggish. This i=
s when
> I am running ktorrent. If I stop the torrent download/upload its fine
> again.
>
> Any idea how to debug this, or why it might be happening. Btw I confi=
rmed
> this behaviour on
>
> kernel 2.8.18.8, 2.6.22, 2.6.23 and latest GIT tree.
>
> P.S: If it matters I am using ipw3945 driver with 2.6.18 kernel and i=
wl3945
> with the newer ones.
>
> Regards,
> ismail



--=20
=46aith is believing what you know isn't so -- Mark Twain
