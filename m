From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/8] qlge: Add firmware coredump functionality.
Date: Sat, 16 Jan 2010 01:02:10 -0800 (PST)
Message-ID: <20100116.010210.82069638.davem@davemloft.net>
References: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49099
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750985Ab0APJCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 04:02:02 -0500
In-Reply-To: <1263598294-5685-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri, 15 Jan 2010 15:31:26 -0800

> 
> Dump all regsiters and on-chip RAM when a fatal firmware error is
> encountered.  This feature is turn OFF by default but can be turned on
> with a module parameter.
> 
> Dave,
> 
> The constant definitions have been cleaned up with aligned tabs per your
> request.  The dump function and it's memory allocation are now turned
> OFF by default.
> I've added/expanded register definitions to aid in dump process which
> gets rid of the literal numeric constants.

Looks good, all applied to net-next-2.6, thanks!
