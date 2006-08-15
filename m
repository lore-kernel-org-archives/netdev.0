From: David Miller <davem@davemloft.net>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Tue, 15 Aug 2006 15:27:59 -0700 (PDT)
Message-ID: <20060815.152759.28786565.davem@davemloft.net>
References: <200608040101.k7411ZZt013801@death.nxdomain.ibm.com>
	<20060814.170905.69218340.davem@davemloft.net>
	<200608152218.k7FMIDZt009900@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Christophe.Devriese@eurid.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:65203
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750756AbWHOW2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 18:28:01 -0400
To: fubar@us.ibm.com
In-Reply-To: <200608152218.k7FMIDZt009900@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 15 Aug 2006 15:18:13 -0700

> 	I have successfully reproduced the problem and subsequently
> validated this patch against 2.6.17.6.  I'm building netdev-2.6#upstream
> right now, but I expect it will work as well (and will report back only
> if it does not).
> 
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>

Thanks a lot for testing Jay.
