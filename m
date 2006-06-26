From: David Boggs <boggs@boggs.palo-alto.ca.us>
Subject: Re: -git: Why is drivers/net/wan/hdlc_generic.c:hdlc_setup() exported?
Date: Sun, 25 Jun 2006 23:11:30 -0700
Message-ID: <200606260611.k5Q6BUSO017145@gw.wa3dbj.vix.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from djb-pa.isc.org ([192.5.4.166]:32453 "EHLO gw.wa3dbj.vix.com")
	by vger.kernel.org with ESMTP id S1751067AbWFZGMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 02:12:52 -0400
To: Adrian Bunk <bunk@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Resent because I forgot to copy netdev on my answer]

I asked Krzysztof to export that so that I could use it
in a re-written driver for LMC WAN cards which I put out
for comments on netdev in March.

I have incorporated the comments from the March posting and
intend to repost the new driver very soon.  If you delete
the export then I will have to write some nasty code to work
around it.

	/David Boggs



