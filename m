From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/15] [IPV4]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:14:32 -0800 (PST)
Message-ID: <20080228.141432.76929984.davem@davemloft.net>
References: <47C693BE.10302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759349AbYB1WOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:14:32 -0500
In-Reply-To: <47C693BE.10302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:58:06 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
