From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4][SCTP]: Don't export include/linux/sctp.h to
 userspace.
Date: Wed, 20 Dec 2006 16:06:07 -0800 (PST)
Message-ID: <20061220.160607.108755214.davem@davemloft.net>
References: <1166659239.5722.15.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161045AbWLUAGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 19:06:09 -0500
To: sri@us.ibm.com
In-Reply-To: <1166659239.5722.15.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 20 Dec 2006 16:00:39 -0800

> [SCTP]: Don't export include/linux/sctp.h to userspace.
> 
> This file contains protocol definitions and there are no SCTP apps that use
> this file.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks for resolving the status of this header file.
