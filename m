From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 18:50:05 +0200
Message-ID: <m3lkg0a88y.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3y7k1biov.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705070343330.2733@scrub.home>
	<m3tzupc6wz.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071318150.1479@scrub.home>
	<m3r6psc0ee.fsf@maximus.localdomain>
	<Pine.LNX.4.64.0705071509290.1479@scrub.home>
	<463F27CE.2040008@garzik.org>
	<Pine.LNX.4.64.0705071538060.1479@scrub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Roman Zippel <zippel@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57869 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934362AbXEGQuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 12:50:07 -0400
In-Reply-To: <Pine.LNX.4.64.0705071538060.1479@scrub.home> (Roman Zippel's message of "Mon, 7 May 2007 15:46:08 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roman Zippel <zippel@linux-m68k.org> writes:

> HDLC doesn't really look like simple library code, what's up with all the 
> HDLC_* options?

Sub-modules. Anyway, what does the patch "screw" exactly?
-- 
Krzysztof Halasa
