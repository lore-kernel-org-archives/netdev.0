From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] SCTP: Implement the receive and verification of
 AUTH chunk
Date: Sun, 16 Sep 2007 19:33:37 -0700 (PDT)
Message-ID: <20070916.193337.40574382.davem@davemloft.net>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
	<11897955003311-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60034
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751105AbXIQCdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 22:33:37 -0400
In-Reply-To: <11897955003311-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 14 Sep 2007 14:44:57 -0400

> This patch implements the receive path needed to process authenticated
> chunks.  Add ability to process the AUTH chunk and handle edge cases
> for authenticated COOKIE-ECHO as well.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, thanks.
