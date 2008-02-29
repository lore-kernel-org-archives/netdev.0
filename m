From: David Miller <davem@davemloft.net>
Subject: Re: take#2 [PATCH 06/15] [IRDA]: Use proc_create() to setup
 ->proc_fops first
Date: Fri, 29 Feb 2008 10:35:07 -0800 (PST)
Message-ID: <20080229.103507.60099931.davem@davemloft.net>
References: <47C69367.6000609@cn.fujitsu.com>
	<20080228.140821.249369808.davem@davemloft.net>
	<47C7AFD2.5080702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756504AbYB2SfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 13:35:07 -0500
In-Reply-To: <47C7AFD2.5080702@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 29 Feb 2008 15:10:10 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks for fixing up this patch.
