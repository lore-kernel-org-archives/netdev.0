From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [NET] rules: Unified rules dumping
Date: Thu, 22 Mar 2007 12:08:27 -0700 (PDT)
Message-ID: <20070322.120827.78720942.davem@davemloft.net>
References: <20070322130302.GX521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33296
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965153AbXCVTI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:08:27 -0400
In-Reply-To: <20070322130302.GX521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 22 Mar 2007 14:03:02 +0100

> Rediffed based on new rtnl registration patches.
> 
> Implements a unified, protocol independant rules dumping function
> which is capable of both, dumping a specific protocol family or
> all of them. This speeds up dumping as less lookups are required.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

This also looks good, applied, thanks Thomas.
