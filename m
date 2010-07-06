From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/6] qlge: fixes for qlge.
Date: Mon, 05 Jul 2010 18:51:53 -0700 (PDT)
Message-ID: <20100705.185153.183036799.davem@davemloft.net>
References: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33714
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752082Ab0GFBvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 21:51:41 -0400
In-Reply-To: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon,  5 Jul 2010 15:19:36 -0700

> 
> 1) Restore promiscuous setting after reset.
> 2) Don't use firmware when forcing firmware dump.
> 3) Reduce print level in data path statements.
> 4) Fix possible endian issue for rx UDP csum.
> 5) Make adapter drop frame errors and pass up csum errors.
> 6) Change version to v1.00.00.25.00.00-01.

All applied, thank you.
