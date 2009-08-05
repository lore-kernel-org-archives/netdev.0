From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix dma mask update calculation
Date: Wed, 05 Aug 2009 10:22:25 -0700 (PDT)
Message-ID: <20090805.102225.60504527.davem@davemloft.net>
References: <1249418343-15741-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.com, netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37306
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934727AbZHERWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 13:22:16 -0400
In-Reply-To: <1249418343-15741-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Tue,  4 Aug 2009 13:39:03 -0700

> Fix dma mask calculation that caps at 63-bit addressing even
> when firmware advertises full 64-bit support.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
