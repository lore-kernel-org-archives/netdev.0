From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 1/9] SCTP: Discard unauthenticated ASCONF and
 ASCONF ACK chunks
Date: Thu, 20 Dec 2007 14:08:13 -0800 (PST)
Message-ID: <20071220.140813.198437898.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762905AbXLTWIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:08:13 -0500
In-Reply-To: <1197927169-5106-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:41 -0500

> Now that we support AUTH, discard unauthenticated ASCONF and ASCONF ACK
> chunks as mandated in the ADD-IP spec.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
