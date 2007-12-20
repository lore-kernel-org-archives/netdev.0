From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 4/9] SCTP: Update association lookup to look at
 ASCONF chunks as well
Date: Thu, 20 Dec 2007 14:10:45 -0800 (PST)
Message-ID: <20071220.141045.221346683.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-5-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755772AbXLTWKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:10:45 -0500
In-Reply-To: <1197927169-5106-5-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:44 -0500

> ADD-IP draft section 5.2 specifies that if an association can not
> be found using the source and destination of the IP packet,
> then, if the packet contains ASCONF chunks, the Address Parameter
> TLV should be used to lookup an association.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
