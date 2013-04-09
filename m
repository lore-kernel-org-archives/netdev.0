From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] cls_cgroup: remove task_struct parameter from
 sock_update_classid()
Date: Tue, 9 Apr 2013 09:35:14 -0400
Message-ID: <20130409133514.GA11337@neilslaptop.think-freely.org>
References: <5163AF37.8010605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42655 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935719Ab3DINf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:35:29 -0400
Content-Disposition: inline
In-Reply-To: <5163AF37.8010605@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 02:03:35PM +0800, Li Zefan wrote:
> The callers always pass current to sock_update_classid().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
