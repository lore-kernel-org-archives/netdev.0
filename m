From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New functions to manipulate registers for ethtool
Date: Mon, 08 Dec 2008 01:57:21 -0800 (PST)
Message-ID: <20081208.015721.27132571.davem@davemloft.net>
References: <58622.1228726903@turing-police.cc.vt.edu>
	<20081208.010634.247305010.davem@davemloft.net>
	<59951.1228728372@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitake@clustcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ktaka@clustcom.com
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43509
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbYLHJ5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:57:20 -0500
In-Reply-To: <59951.1228728372@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valdis.Kletnieks@vt.edu
Date: Mon, 08 Dec 2008 04:26:12 -0500

> On Mon, 08 Dec 2008 01:06:34 PST, David Miller said:
> 
> > That's an awful reason to have to two ways of doing the exact same
> > thing from userspace.
> 
> Which is why 'sysctl' and 'echo > /proc/sys/....' both exist, right?

We're essentially getting rid of the former, so your sarcasm was
poorly applied, sorry.
