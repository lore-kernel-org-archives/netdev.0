From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] tcp: cleanup of htcp
Date: Mon, 12 Feb 2007 13:14:39 -0800 (PST)
Message-ID: <20070212.131439.48527906.davem@davemloft.net>
References: <20070212160317.545906075@linux-foundation.org>
	<20070212160336.337425153@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965417AbXBLVOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 16:14:42 -0500
In-Reply-To: <20070212160336.337425153@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 12 Feb 2007 08:03:18 -0800

> Minor non-invasive cleanups:
>  * white space around operators and line wrapping
>  * use const
>  * use __read_mostly
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Yoshifuji fixed all the whitespace issues in the entire
net/ subtree the other day using an automated script,
so you'll need to re-patch this against Linus's current
tree as it doesn't apply cleanly.

Thanks.
