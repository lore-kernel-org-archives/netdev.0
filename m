From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] santize tc_ematch headers
Date: Wed, 22 Aug 2007 12:36:21 -0700 (PDT)
Message-ID: <20070822.123621.22279151.davem@davemloft.net>
References: <20070822101838.31178935@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49914
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756510AbXHVTgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 15:36:33 -0400
In-Reply-To: <20070822101838.31178935@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 22 Aug 2007 10:18:38 -0700

> The headers in tc_ematch are used by iproute2, so these headers
> should be processed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
