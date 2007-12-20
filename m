From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 3/9] SCTP: Add the handling of "Set Primary IP
 Address" parameter to INIT
Date: Thu, 20 Dec 2007 14:10:07 -0800 (PST)
Message-ID: <20071220.141007.142524341.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-4-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37575
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753620AbXLTWKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:10:07 -0500
In-Reply-To: <1197927169-5106-4-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:43 -0500

> The ADD-IP "Set Primary IP Address" parameter is allowed in the
> INIT/INIT-ACK exchange.  Allow processing of this parameter during
> the INIT/INIT-ACK.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
