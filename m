From: David Miller <davem@davemloft.net>
Subject: Re: [6PACK] Masking bug in 6pack driver
Date: Thu, 23 Nov 2006 11:48:47 -0800 (PST)
Message-ID: <20061123.114847.93384936.davem@davemloft.net>
References: <20061123183023.GA6556@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:11980
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933673AbWKWTsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 14:48:41 -0500
To: ralf@linux-mips.org
In-Reply-To: <20061123183023.GA6556@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 23 Nov 2006 18:30:23 +0000

> Looks like a broken masking to me, binary not is used where bitwise not
> was intended.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Jeff, I've got this one.

Applied, thanks a lot!
