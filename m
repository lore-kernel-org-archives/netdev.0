From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] [SCTP]: Add back the code that accounted for
 FORWARD_TSN parameter in INIT.
Date: Mon, 07 Jan 2008 00:28:35 -0800 (PST)
Message-ID: <20080107.002835.241929571.davem@davemloft.net>
References: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
	<1199475946-11103-4-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754945AbYAGI2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 03:28:35 -0500
In-Reply-To: <1199475946-11103-4-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  4 Jan 2008 14:45:46 -0500

> Some recent changes completely removed accounting for the FORWARD_TSN
> parameter length in the INIT and INIT-ACK chunk.  This is wrong and
> should be restored.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Also applied, thanks Vlad.
