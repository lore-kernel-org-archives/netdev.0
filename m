From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix detection of cut-thru firmware mode
Date: Thu, 18 Jun 2009 00:46:50 -0700 (PDT)
Message-ID: <20090618.004650.107063746.davem@davemloft.net>
References: <1245295645-22573-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759010AbZFRHqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:46:47 -0400
In-Reply-To: <1245295645-22573-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Wed, 17 Jun 2009 20:27:24 -0700

> Fix the detection of cut-thru mode of the hardware (direct dma
> to host) to mode configured in SRE (ingress block) rather than
> onboard memory control.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
