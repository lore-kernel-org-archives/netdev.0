From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netxen: fix detection of cut-thru firmware mode
Date: Thu, 18 Jun 2009 11:56:10 -0700 (PDT)
Message-ID: <20090618.115610.266594120.davem@davemloft.net>
References: <1245338871-27112-1-git-send-email-dhananjay@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753726AbZFRS4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 14:56:07 -0400
In-Reply-To: <1245338871-27112-1-git-send-email-dhananjay@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@qlogic.com>
Date: Thu, 18 Jun 2009 08:27:50 -0700

> Fix the detection of cut-thru mode of the hardware (direct dma
> to host) to mode configured in SRE (ingress block) rather than
> onboard memory control.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@qlogic.com>

Why are you sending these patches again?  I already applied
them.
