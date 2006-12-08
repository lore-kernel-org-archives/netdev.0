From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] Fix XFRMGRP_REPORT to use correct multicast
 group
Date: Fri, 08 Dec 2006 00:12:45 -0800 (PST)
Message-ID: <20061208.001245.98554316.davem@davemloft.net>
References: <1165536898.3666.3.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38227
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425151AbWLHIMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 03:12:31 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165536898.3666.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 07 Dec 2006 19:14:58 -0500

> Against net-2.6 but should probably go into anything stable that has
> reports already.

Applied, thanks for this fix Jamal.  I'll push it to -stable.
