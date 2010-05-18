From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ibmveth: Add suspend/resume support
Date: Mon, 17 May 2010 17:09:21 -0700 (PDT)
Message-ID: <20100517.170921.183060241.davem@davemloft.net>
References: <201005071156.o47BuCYM007062@d03av03.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752090Ab0ERAJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:09:12 -0400
In-Reply-To: <201005071156.o47BuCYM007062@d03av03.boulder.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian King <brking@linux.vnet.ibm.com>
Date: Fri, 07 May 2010 13:56:08 -0500

> 
> Adds support for resuming from suspend for IBM virtual ethernet devices.
> We may have lost an interrupt over the suspend, so we just kick the
> interrupt handler to process anything that is outstanding.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

Applied, thank you.
