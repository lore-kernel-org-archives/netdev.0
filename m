From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: garp: retry sending JoinIn messages after allocation
 failures
Date: Wed, 16 Jul 2008 20:52:01 -0700 (PDT)
Message-ID: <20080716.205201.37461910.davem@davemloft.net>
References: <487C9FFB.5060103@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60010
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754355AbYGQDwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:52:02 -0400
In-Reply-To: <487C9FFB.5060103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 15 Jul 2008 15:02:51 +0200

>     garp: retry sending JoinIn messages after allocation failures
>     
>     Increase reliability by retrying to send JoinIn messages after memory
>     allocation failures on each TRANSMIT_PDU event until it succeeds.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
