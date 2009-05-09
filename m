From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 3/4] netxen: disable msi-x for NC512m adapter
Date: Sat, 09 May 2009 13:17:36 -0700 (PDT)
Message-ID: <20090509.131736.99147820.davem@davemloft.net>
References: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
	<1241856150-4488-3-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43085
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753761AbZEIURk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:17:40 -0400
In-Reply-To: <1241856150-4488-3-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat,  9 May 2009 01:02:29 -0700

> This board doesn't suppot msi-x well due to msi-x table
> mapping (hardware) issue.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
