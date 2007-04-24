From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] TCP YEAH: use vegas dont copy it
Date: Mon, 23 Apr 2007 22:35:24 -0700 (PDT)
Message-ID: <20070423.223524.94889772.davem@davemloft.net>
References: <20070424033117.873984872@linux-foundation.org>
	<20070424033317.201165857@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-founsation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161632AbXDXFfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 01:35:17 -0400
In-Reply-To: <20070424033317.201165857@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-founsation.org>
Date: Mon, 23 Apr 2007 20:31:21 -0700

> Rather than using a copy of vegas code, the YEAH code should just
> have it exported so there is common code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Excellent cleanup.

Applied, thanks Stephen.
