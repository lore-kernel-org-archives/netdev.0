From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] atl1c: Add missing PCI device ID
Date: Wed, 02 Feb 2011 15:02:34 -0800 (PST)
Message-ID: <20110202.150234.260102540.davem@davemloft.net>
References: <20110202105902.3c0d2f9e@katamari>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jie.Yang@atheros.com
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755268Ab1BBXB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:01:58 -0500
In-Reply-To: <20110202105902.3c0d2f9e@katamari>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chuck Ebbert <cebbert@redhat.com>
Date: Wed, 2 Feb 2011 10:59:02 -0500

> 
> Commit 8f574b35f22fbb9b5e5f1d11ad6b55b6f35f4533 added support for a new
> adapter but failed to add it to the PCI device table.
> 
> Signed-Off-By: Chuck Ebbert <cebbert@redhat.com>

Applied, thanks Chuck.
