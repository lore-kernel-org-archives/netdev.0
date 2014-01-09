From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 4/4] bonding: update bonding.txt for primary
 description
Date: Thu, 9 Jan 2014 12:49:43 +0100
Message-ID: <20140109114943.GI5786@redhat.com>
References: <52CE8619.7080602@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbaAILws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 06:52:48 -0500
Content-Disposition: inline
In-Reply-To: <52CE8619.7080602@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 09, 2014 at 07:20:57PM +0800, Ding Tianhong wrote:
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

This one's good.

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>---
> Documentation/networking/bonding.txt | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)
>
>diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
>index a4d925e..5cdb229 100644
>--- a/Documentation/networking/bonding.txt
>+++ b/Documentation/networking/bonding.txt
>@@ -657,7 +657,8 @@ primary
> 	one slave is preferred over another, e.g., when one slave has
> 	higher throughput than another.
>
>-	The primary option is only valid for active-backup mode.
>+	The primary option is only valid for active-backup(1),
>+	balance-tlb (5) and balance-alb (6) mode.
>
> primary_reselect
>
>-- 
>1.8.0
>
>
