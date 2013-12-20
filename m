From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 4/5] sctp: fix checkpatch errors
Date: Fri, 20 Dec 2013 09:51:21 -0500
Message-ID: <20131220145121.GE6562@hmsreliant.think-freely.org>
References: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
 <1387435922-24152-5-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47693 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab3LTOv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:51:26 -0500
Content-Disposition: inline
In-Reply-To: <1387435922-24152-5-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 02:52:01PM +0800, Wang Weidong wrote:
> fix up checkpatch errors:
> that open brace { should be on the previous line
> open brace '{' following function declarations go on the next line
> ERROR: trailing statements should be on next line
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
These are all checkpatch errors.  You could have just merged them into a big
patch.  Since you didn't, please be a bit more articulate in describing what
they do in the subject line.

Neil
