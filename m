From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Subject: Re: [PATCHv2] tun: fix carrier on/off status
Date: Sat, 02 Feb 2013 11:27:29 +0100
Message-ID: <510CEA11.9060802@gmx.de>
References: <5103B01D.5070303@gmx.de> <3592886.xagLc7Uij9@jason-thinkpad-t430s> <20130128101111.GB5337@redhat.com> <20130128103801.GA6648@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:65514 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755475Ab3BBK1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2013 05:27:34 -0500
Received: from mailout-de.gmx.net ([10.1.76.4]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0M3gid-1UsS5V0nWz-00rDTb for
 <netdev@vger.kernel.org>; Sat, 02 Feb 2013 11:27:32 +0100
In-Reply-To: <20130128103801.GA6648@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Between v3.8.0-rc5+ and v3.8.0-rc6+ the following dmesg are new :

> br0: port 4(tap3) entered forwarding state
> br0: port 4(tap3) entered forwarding state
> br0: port 3(tap2) entered forwarding state
> br0: port 3(tap2) entered forwarding state
> br0: port 2(tap1) entered forwarding state
> br0: port 2(tap1) entered forwarding state
> br0: port 1(tap0) entered forwarding state
> br0: port 1(tap0) entered forwarding state

Is this related to the original mail too ?

--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
