From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 11:35:56 +0200
Message-ID: <m3tzupc6wz.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3y7k1biov.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705070343330.2733@scrub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Roman Zippel <zippel@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46913 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125AbXEGJf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 05:35:58 -0400
In-Reply-To: <Pine.LNX.4.64.0705070343330.2733@scrub.home> (Roman Zippel's message of "Mon, 7 May 2007 03:44:37 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roman Zippel <zippel@linux-m68k.org> writes:

> What's the advantage? The HDLC option is directly before this?

You don't have to know it's required, you can just select a driver
for your hardware, without enabling HDLC first.
-- 
Krzysztof Halasa
