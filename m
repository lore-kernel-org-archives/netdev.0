From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qlge: Move reset from eeh io_resume to
 slot_reset.
Date: Wed, 03 Feb 2010 20:06:10 -0800 (PST)
Message-ID: <20100203.200610.201810517.davem@davemloft.net>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com>
	<1265217853-26959-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56866
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756271Ab0BDEF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 23:05:57 -0500
In-Reply-To: <1265217853-26959-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed,  3 Feb 2010 09:24:11 -0800

> Issue asic reset and verify functionality before continuing to the
> resume call.  This allows proper error code to be returned in the case
> the asic does not recover.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
