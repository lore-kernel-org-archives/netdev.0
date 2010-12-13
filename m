From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] cpmac: remove unused buflen
Date: Mon, 13 Dec 2010 10:15:37 -0800 (PST)
Message-ID: <20101213.101537.59685214.davem@davemloft.net>
References: <20101213171725.2ed299cf.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ejka@imfi.kspu.ru
To: yuasa@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41575
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751146Ab0LMSPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:15:09 -0500
In-Reply-To: <20101213171725.2ed299cf.yuasa@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoichi Yuasa <yuasa@linux-mips.org>
Date: Mon, 13 Dec 2010 17:17:25 +0900

> Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>

This is a descriptor read by and used by the hardware, you cannot just
delete it.
