From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] vmxnet: trivial annotation of protocol constant
Date: Sat, 30 Oct 2010 16:19:53 -0700 (PDT)
Message-ID: <20101030.161953.39185823.davem@davemloft.net>
References: <1288235555-24675-1-git-send-email-harvey.harrison@gmail.com>
	<1288235555-24675-2-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55490
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754002Ab0J3XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 19:19:30 -0400
In-Reply-To: <1288235555-24675-2-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 27 Oct 2010 20:12:35 -0700

> Noticed by sparse:
> drivers/net/vmxnet3/vmxnet3_drv.c:876:38: warning: cast from restricted __be16
> drivers/net/vmxnet3/vmxnet3_drv.c:876:38: warning: cast from restricted __be16
> drivers/net/vmxnet3/vmxnet3_drv.c:876:24: warning: restricted __be16 degrades to integer
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
