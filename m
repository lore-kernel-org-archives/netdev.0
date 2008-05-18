From: Nate Case <ncase@xes-inc.com>
Subject: Re: [PATCH v4] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Sat, 17 May 2008 20:27:35 -0500
Message-ID: <1211074055.13845.543.camel@localhost.localdomain>
References: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:49632 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbYERB1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 21:27:49 -0400
In-Reply-To: <Pine.LNX.4.55.0805170619390.4049@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-05-17 at 06:40 +0100, Maciej W. Rozycki wrote:
> Configure the BCM5482S secondary SerDes for 1000Base-X mode when the
> appropriate dev_flags are passed in to phy_connect().  This is
> needed when the PHY is used for fiber and backplane connections.
[snip]
> Jeff,
> 
>  I have removed unnecessary "inline" annotations and made a few
> formatting
> adjustments.  I hope Nate agrees with these changes.  Please apply.

The changes look good to me.

-- 
Nate Case <ncase@xes-inc.com>

