From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 6/9] SCTP: Update ASCONF processing to conform
 to spec.
Date: Thu, 20 Dec 2007 14:11:55 -0800 (PST)
Message-ID: <20071220.141155.30522839.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-7-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37625
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753156AbXLTWLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:11:55 -0500
In-Reply-To: <1197927169-5106-7-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:46 -0500

> The processing of the ASCONF chunks has changed a lot in the
> spec.  New items are:
>     1. A list of ASCONF-ACK chunks is now cached
>     2. The source of the packet is used in response.
>     3. New handling for unexpect ASCONF chunks.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
