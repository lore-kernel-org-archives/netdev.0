From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: e1000 driver problems
Date: Mon, 3 Dec 2007 10:50:23 +0100
Message-ID: <20071203095023.GG26573@ics.muni.cz>
References: <20061017205316.25914.qmail@web83109.mail.mud.yahoo.com> <45354850.6050900@intel.com> <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com> <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:41019 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbXLCJut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 04:50:49 -0500
Content-Disposition: inline
In-Reply-To: <474C6084.9000301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 27, 2007 at 10:23:00AM -0800, Kok, Auke wrote:
> can you see if your problem goes away with this patch?

I cannot test it right now but friend of mine has the same card with 2.=
6.23.1
kernel. it does not. he also tried module 7.6.12 from source fourge, yo=
ur patch
did not help. Moreover, it just hangs network connections after while. =
No
message in dmesg about hangup.

--=20
Luk=E1=B9 Hejtm=E1nek
