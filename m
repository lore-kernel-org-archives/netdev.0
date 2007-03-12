From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] net: make seq_operations const
Date: Mon, 12 Mar 2007 14:34:47 -0700 (PDT)
Message-ID: <20070312.143447.08320216.davem@davemloft.net>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.658532320@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932244AbXCLVet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:34:49 -0400
In-Reply-To: <20070312210907.658532320@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Mar 2007 14:08:19 -0700

> The seq_file operations stuff can be marked constant to
> get it out of dirty cache.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
