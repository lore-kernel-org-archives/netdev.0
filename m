From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/15] [NEIGHBOUR]: Use proc_create() to setup
 ->proc_fops first
Date: Thu, 28 Feb 2008 14:10:58 -0800 (PST)
Message-ID: <20080228.141058.240639463.davem@davemloft.net>
References: <47C69383.4070505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752482AbYB1WK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 17:10:59 -0500
In-Reply-To: <47C69383.4070505@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:57:07 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

APplied.
