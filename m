From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/5] ipv6: make inet6_register_protosw to return an
 error code
Date: Tue, 11 Dec 2007 02:25:12 -0800 (PST)
Message-ID: <20071211.022512.181011008.davem@davemloft.net>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071210151437.362338020@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbXLKKZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:25:13 -0500
In-Reply-To: <20071210151437.362338020@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 10 Dec 2007 16:09:14 +0100

> This patch makes the inet6_register_protosw to return an error code.
> The different protocols can be aware the registration was successful or
> not and can pass the error to the initial caller, af_inet6.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
