From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix the version code macro
Date: Thu, 02 Jul 2009 13:17:33 -0700 (PDT)
Message-ID: <20090702.131733.99266584.davem@davemloft.net>
References: <1246484503-10817-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38069
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757002AbZGBUR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 16:17:27 -0400
In-Reply-To: <1246484503-10817-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed,  1 Jul 2009 14:41:42 -0700

> Correct firmware encoding is 8 bit major, 8 bit minor and
> 16 bit subversion. Flash has sizes rightly set, but original
> driver submission messed it leaving 16 bit major and 8 bit
> subversion.
> 
> Also fix a infinite loop when cut-thru file firmware is
> invalid.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
