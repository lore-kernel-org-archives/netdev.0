From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] TCP Illinois update
Date: Mon, 23 Apr 2007 22:34:56 -0700 (PDT)
Message-ID: <20070423.223456.69410532.davem@davemloft.net>
References: <20070424033117.873984872@linux-foundation.org>
	<20070424033317.042343204@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-founsation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33915
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161636AbXDXFes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 01:34:48 -0400
In-Reply-To: <20070424033317.042343204@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-founsation.org>
Date: Mon, 23 Apr 2007 20:31:19 -0700

> This version more closely matches the paper, and fixes several
> math errors. The biggest difference is that it updates alpha/beta
> once per RTT
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks.
