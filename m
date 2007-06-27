From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV6] MIP6: Kill unnecessary ifdefs.
Date: Tue, 26 Jun 2007 23:53:00 -0700 (PDT)
Message-ID: <20070626.235300.112853061.davem@davemloft.net>
References: <1179906618559-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752711AbXF0Gwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 02:52:40 -0400
In-Reply-To: <1179906618559-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: nakam@linux-ipv6.org
Date: Wed, 23 May 2007 16:50:18 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> Kill unnecessary CONFIG_IPV6_MIP6.
> 
> o It is redundant for RAW socket to keep MH out with the config then
>   it can handle any protocol.
> o Clean-up at AH.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied to net-2.6.23, thank you!
