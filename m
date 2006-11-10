From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Fri, 10 Nov 2006 14:38:01 -0800 (PST)
Message-ID: <20061110.143801.39158000.davem@davemloft.net>
References: <200611101609.21333@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2281
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424420AbWKJWiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:38:00 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611101609.21333@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I can't apply any of this Gerrit.

What makes net/ipv4/udplite.c get built at all?  I see no
changes to net/ipv4/Makefile, so you must have stuffed up
the generation of your patches.

Please resubmit all 3 patches once you've corrected this
and actually _tested_ the patch you submitted.  You know,
because I might actually try to build what you send me :-)
