From: David Miller <davem@davemloft.net>
Subject: Re: take#4: [PATCH] [ATM]: Add error handling for proc_create fail
Date: Sun, 23 Mar 2008 21:47:26 -0700 (PDT)
Message-ID: <20080323.214726.07039365.davem@davemloft.net>
References: <20080302.210926.16120136.davem@davemloft.net>
	<47CBBAD8.2010802@cn.fujitsu.com>
	<47CCF9ED.1050006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas3@users.sourceforge.net
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751365AbYCXEr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 00:47:26 -0400
In-Reply-To: <47CCF9ED.1050006@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 04 Mar 2008 15:27:41 +0800

> When proc_create() fails, do some error handling work and return -ENOMEM.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks a lot.
