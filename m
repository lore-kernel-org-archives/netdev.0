From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] [NIU] Redo: Determine the # of ports from the card's
 VPD data
Date: Fri, 09 May 2008 14:35:30 -0700 (PDT)
Message-ID: <20080509.143530.115824166.davem@davemloft.net>
References: <48249647.2000505@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37767
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754569AbYEIVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 17:35:36 -0400
In-Reply-To: <48249647.2000505@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Fri, 09 May 2008 11:21:59 -0700

> Signed-off-by: Matheos <matheos.worku@sun.com>

Missing your last name.

> @@ -865,7 +865,6 @@ static int link_status_1g_serdes(struct niu *np, int 
> *link_up_p)
>   	return 0;
>   }

Your email client corrupted the patch by chopping up long lines.
