From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [SCTP]: Set correct error cause value for missing
 parameters
Date: Mon, 15 Jan 2007 19:12:34 -0800 (PST)
Message-ID: <20070115.191234.71093024.davem@davemloft.net>
References: <1168544485.22592.18.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751429AbXAPDMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:12:33 -0500
To: sri@us.ibm.com
In-Reply-To: <1168544485.22592.18.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 11 Jan 2007 11:41:25 -0800

> [SCTP]: Set correct error cause value for missing parameters
> 
> sctp_process_missing_param() needs to use the SCTP_ERROR_MISS_PARAM
> error cause value.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thank you.
