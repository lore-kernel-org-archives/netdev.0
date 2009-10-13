From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cosa: Kill off the use of the old ioctl path
Date: Tue, 13 Oct 2009 12:14:06 -0700 (PDT)
Message-ID: <20091013.121406.56931065.davem@davemloft.net>
References: <20091013153045.20012.76202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752348AbZJMTOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 15:14:10 -0400
In-Reply-To: <20091013153045.20012.76202.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>
Date: Tue, 13 Oct 2009 16:30:46 +0100

> Signed-off-by: Alan Cox <alan@linux.intel.com>
> ---
> 
>  drivers/message/i2o/i2o_config.c |    5 ++---
>  drivers/net/wan/cosa.c           |   18 ++++++++++++------
>  2 files changed, 14 insertions(+), 9 deletions(-)

I don't think you meant to put the I2O bits in here. :-)

Please fully resubmit this with that fixed up.

Thanks!
