From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: Bluetooth wireless mouse very sluggish when there is moderated
 network activity
Date: Sun, 14 Oct 2007 13:27:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710141326000.25413@twin.jikos.cz>
References: <200710131713.03345.ismail@pardus.org.tr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1747641777-234131158-1192361257=:25413"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ismail =?utf-8?q?D=C3=B6nmez?= <ismail@pardus.org.tr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from twin.jikos.cz ([213.151.79.26]:49351 "EHLO twin.jikos.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540AbXJNL2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 07:28:05 -0400
In-Reply-To: <200710131713.03345.ismail@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1747641777-234131158-1192361257=:25413
Content-Type: TEXT/PLAIN; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 13 Oct 2007, Ismail D=F6nmez wrote:

> input: Microsoft Microsoft? Wireless Notebook Presenter Mouse 8000 as=20
> /devices/pci0000:00/0000:00:1d.1/usb3/3-1/3-1.3/3-1.3:1.0/input/input12=
=20
> input: USB HID v1.11 Mouse [Microsoft Microsoft? Wireless Notebook=20
> Presenter Mouse 8000] on usb-0000:00:1d.1-1.3 Problem is when there is a=
=20
> moderate traffic on wireless interface (300-400k/s down 50-60k/up on=20
> 4Mbit) mouse is really sluggish. This is when I am running ktorrent. If=
=20
> I stop the torrent download/upload its fine again.
> P.S: If it matters I am using ipw3945 driver with 2.6.18 kernel and iwl39=
45=20
> with the newer ones.

Hi Ismail,

it would be great if you'd be able to isolate what is the cause in a=20
little more detailed way - i.e. try a different network card in the same=20
machine, try a different bluetooth mouse in the same machine, try the very=
=20
same mouse and network card in a different machine, etc.

Otherwise I am afraid this is going to be just a totally wild guessing.

Thanks,

--=20
Jiri Kosina
---1747641777-234131158-1192361257=:25413--
