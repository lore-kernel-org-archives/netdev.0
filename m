From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/5] ipv6: make flowlabel to return an error
Date: Tue, 11 Dec 2007 02:23:31 -0800 (PST)
Message-ID: <20071211.022331.267843823.davem@davemloft.net>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071210151425.106827965@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48357
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751577AbXLKKXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:23:32 -0500
In-Reply-To: <20071210151425.106827965@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 10 Dec 2007 16:09:11 +0100

> This patch makes the flowlab subsystem to return an error code and makes
> some cleanup with procfs ifdefs.
> The af_inet6 will use the flowlabel init return code to check the initialization
> was correct.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
