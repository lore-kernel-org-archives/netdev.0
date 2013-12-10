From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 1/1] drivers: net : cpsw: Use netdev_name while requesting
 irq
Date: Tue, 10 Dec 2013 14:02:55 +0530
Message-ID: <52A6D1B7.60308@ti.com>
References: <1386313107-8597-1-git-send-email-mugunthanvnm@ti.com>	<20131206.154640.2274056773488827363.davem@davemloft.net>	<52A58D61.9060404@ti.com> <20131209.195706.1978243618769759438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<george.cherian@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:42238 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab3LJIc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 03:32:57 -0500
In-Reply-To: <20131209.195706.1978243618769759438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 10 December 2013 06:27 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Mon, 9 Dec 2013 14:59:05 +0530
>
>> commit 50a5fb068
> This commit doesn't appear in any tree.
>
> And any change which makes a real "struct device" return NULL
> for dev_name() is broken.
>
> I'm not applying this patch, you have completely failed to
> provide any information necessary to support and justify
> your change.
Oops, the commit ID is wrong my mistake, since you have dropped this
patch, I will submit the patch again with more details.

Regards
Mugunthan V N
