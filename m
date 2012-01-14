From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Sat, 14 Jan 2012 15:34:02 +0100
Message-ID: <CACna6rw1z7RRBSwpE6O2GXMMMTE+Q+4JvMXpYaNLJfHjEM5aRQ@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
	<1326440480-26271-1-git-send-email-zajec5@gmail.com>
	<alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
	<4F101047.4090902@broadcom.com>
	<CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
	<20120114122222.GA21233@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Dominique Martinet <asmadeus@codewreck.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64989 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754653Ab2ANOeD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 09:34:03 -0500
Received: by wibhm14 with SMTP id hm14so1035892wib.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 06:34:02 -0800 (PST)
In-Reply-To: <20120114122222.GA21233@nautica>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/14 Dominique Martinet <asmadeus@codewreck.org>:
> By the way, resume/suspend works with your patches over linux-next.gi=
t
> with a bcm4313 on a eeepc1215b!

Do you mean hibernate, AKA suspend to disk? I've Asus EEEPC 1215B with
AMD E-450 and after
echo disk > /sys/power/state
it tries to hibernate, but resumes right after, before even stopping
CPU or disabling backlight.

--=20
Rafa=C5=82
