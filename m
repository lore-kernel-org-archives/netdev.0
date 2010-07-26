From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [PATCH] s2io: fixing DBG_PRINT() macro
Date: Mon, 26 Jul 2010 15:37:42 -0700 (PDT)
Message-ID: <20100726.153742.229757275.davem@davemloft.net>
References: <1280156836-16138-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43852
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751874Ab0GZWhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 18:37:25 -0400
In-Reply-To: <1280156836-16138-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Mon, 26 Jul 2010 12:07:16 -0300

> Patch 9e39f7c5b311a306977c5471f9e2ce4c456aa038 changed the
> DBG_PRINT() macro and the if clause was wrongly changed. It means
> that currently all the DBG_PRINT are being printed, flooding the
> kernel log buffer with things like:
> 
> s2io: eth6: Next block at: c0000000b9c90000
> s2io: eth6: In Neterion Tx routine
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Acked-by: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>

Applied, thanks.
