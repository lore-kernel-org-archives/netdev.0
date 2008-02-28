From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/15] [X25]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:16:39 -0800 (PST)
Message-ID: <20080228.141639.219429554.davem@davemloft.net>
References: <47C693E8.7040003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757777AbYB1WQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:16:40 -0500
In-Reply-To: <47C693E8.7040003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:58:48 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
