From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix msi-x interrupt handling
Date: Sun, 08 Feb 2009 19:20:26 -0800 (PST)
Message-ID: <20090208.192026.233301958.davem@davemloft.net>
References: <1234027410-658-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753592AbZBIDUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 22:20:32 -0500
In-Reply-To: <1234027410-658-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat,  7 Feb 2009 09:23:30 -0800

> o Cut down msi-x vectors from 8 to 1 since only one is used for now.
> o Use separate handler for msi-x, that doesn't unnecessarily scrub
>   msi status register.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied, thanks.
