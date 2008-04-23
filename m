From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport move_addr_to_{kernel,user}
Date: Wed, 23 Apr 2008 03:38:01 -0700 (PDT)
Message-ID: <20080423.033801.13598321.davem@davemloft.net>
References: <20080423095145.GB28933@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750758AbYDWKiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:38:00 -0400
In-Reply-To: <20080423095145.GB28933@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Wed, 23 Apr 2008 12:51:45 +0300

> After the removal of the Solaris binary emulation the exports of 
> move_addr_to_{kernel,user} are no longer used.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks Adrian.
