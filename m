From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/15] [LLC]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 14:09:01 -0800 (PST)
Message-ID: <20080228.140901.252748968.davem@davemloft.net>
References: <47C69376.9030303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755317AbYB1WJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:09:01 -0500
In-Reply-To: <47C69376.9030303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:56:54 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
