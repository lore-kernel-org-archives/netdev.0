From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/5] sctp: fix checkpatch errors with foo
Date: Fri, 20 Dec 2013 09:44:06 -0500
Message-ID: <20131220144406.GC6562@hmsreliant.think-freely.org>
References: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
 <1387435922-24152-3-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47575 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551Ab3LTOoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:44:30 -0500
Content-Disposition: inline
In-Reply-To: <1387435922-24152-3-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 02:51:59PM +0800, Wang Weidong wrote:
> fix three foo type errors below:
> ERROR: "(foo*)" should be "(foo *)"
> ERROR: "foo * bar" should be "foo *bar"
> ERROR: "foo* bar" should be "foo *bar"
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Could you come up with a more descriptive subject line please.  I understand the
meaning, but anyone not familiar with checkpatch won't have any idea what that
means.
Neil
