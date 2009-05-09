From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 1/4] netxen: cache msi register offset
Date: Sat, 09 May 2009 13:17:24 -0700 (PDT)
Message-ID: <20090509.131724.238373417.davem@davemloft.net>
References: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43079
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753149AbZEIUR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:17:28 -0400
In-Reply-To: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat,  9 May 2009 01:02:27 -0700

> Store msi target status register offset in adapter struct.
> This avoids contention on msi_tgt_status table from interrupt
> hadlers of different pci function.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
