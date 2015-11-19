From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 15:54:28 -0800
Message-ID: <CANP3RGc9NY7yRNAtssx3rHusCreNbFw19cuQB2ejWMnnQnVLvQ@mail.gmail.com>
References: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
	<20151118.153508.123902005995190872.davem@davemloft.net>
	<1447879416.562854.443622857.62708268@webmail.messagingengine.com>
	<20151118.224919.452852815199526735.davem@davemloft.net>
	<CALx6S36-tBwAGFFpdrhXjAXvNmxUXsbRV17Wayjr6-hsKsCeNg@mail.gmail.com>
	<1447948469.2030778.444426889.4F4A5648@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36313 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbKSXy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 18:54:29 -0500
Received: by igcph11 with SMTP id ph11so150047igc.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 15:54:28 -0800 (PST)
In-Reply-To: <1447948469.2030778.444426889.4F4A5648@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ack. With emphasis of *application*. :)

The problem with application anything is that changing apps is
outright impossible.
There are far too many of them written by far too many people.
And until you fix them all (which is infeasible) and roll those
changes out (unlikely) users will continue to suffer.

You are free to change the kernel, you are free to change some (or a
few) network management daemon(s), you are not free to update every
application out there.
