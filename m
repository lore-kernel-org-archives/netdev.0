From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: g3 + HP iLO2 -> IPv6 broken
Date: Wed, 1 Oct 2008 01:30:42 +0200
Message-ID: <20080930233042.GB18447@pest>
References: <gbu10u$uvr$1@ger.gmane.org> <20080930225334.GA735@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:50269 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754631AbYI3Xa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 19:30:57 -0400
Content-Disposition: inline
In-Reply-To: <20080930225334.GA735@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 03:53:34PM -0700, Matt Carlson wrote:

> It sounds like the iLO2 firmware is messing around with the rx filter.
> I've heard of problems like this before with another management agent.
> 
> Can you give me the output to 'ethtool -i <device>' and the iLO2
> firmware version?

svr01:~# ethtool -i eth0
driver: tg3
version: 3.94
firmware-version: 5715-v3.28, UMP 1.15
bus-info: 0000:03:04.0

iLO 2 Standard 1.60 at 16:05:58 Jul 11 2008
Server Name: DL320G5P0200
Server Power: On

Regards,
Bernhard
