From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: use proc_create_data()
Date: Fri, 28 Aug 2009 23:34:53 -0700 (PDT)
Message-ID: <20090828.233453.08272750.davem@davemloft.net>
References: <20090828194721.GD14499@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751606AbZH2Gej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:34:39 -0400
In-Reply-To: <20090828194721.GD14499@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 28 Aug 2009 23:47:21 +0400

> It looks like after rename device proc entry is unusable,
> because of no ->read_proc or ->proc_fops.
> 
> And create_proc_entry() is deprecated.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
