From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Thu, 19 Jan 2012 08:15:40 -0800
Message-ID: <CA+55aFxGHueSjP4xv=1+o_pv1eDsNgTUcx+k43sGkvbO9SHTGw@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com> <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <4F142D84.4060405@broadcom.com> <4F145F52.9010200@broadcom.com>
 <CA+55aFyMY5o7irG+=c4ZrfftMu6OJvoyFFY4KNO8rCe90P0mhw@mail.gmail.com> <4F1808A5.4070502@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56901 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482Ab2ASQQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 11:16:02 -0500
Received: by wgbdq11 with SMTP id dq11so102730wgb.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 08:16:01 -0800 (PST)
In-Reply-To: <4F1808A5.4070502@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/19 Arend van Spriel <arend@broadcom.com>:
>
> As the patches are in wireless-testing I tested suspend/resume on my
> system. Worked fine and NetworkManager reestablished the wireless
> connection.

Ok, thanks. Let's hope the nvidia problem can be fixed quickly, but at
least we can put the brcmsmac issue to rest.

                            Linus
