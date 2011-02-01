From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] depca: Fix warnings
Date: Tue, 01 Feb 2011 13:19:28 -0800 (PST)
Message-ID: <20110201.131928.112605715.davem@davemloft.net>
References: <20110201113214.24608.34659.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53067
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751812Ab1BAVSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 16:18:53 -0500
In-Reply-To: <20110201113214.24608.34659.stgit@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 01 Feb 2011 11:32:29 +0000

> From: Alan Cox <alan@linux.intel.com>
> 
> Replace the rather weird use of ++ with + 1 as the value is being assigned
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied, thanks Alan.
