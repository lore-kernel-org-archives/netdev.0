From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] vxlan: using kfree_rcu() to simplify the code
Date: Tue, 16 Jul 2013 23:01:44 -0700 (PDT)
Message-ID: <20130716.230144.794838870525114679.davem@davemloft.net>
References: <CAPgLHd89R4FkKq1tCyuL9WWRXgsCb7ZpGGsw3yiPn1Ht5X61Vw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com,
	mike.rapoport@ravellosystems.com, amwang@redhat.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab3GQGBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 02:01:48 -0400
In-Reply-To: <CAPgLHd89R4FkKq1tCyuL9WWRXgsCb7ZpGGsw3yiPn1Ht5X61Vw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 17 Jul 2013 13:29:58 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The callback function of call_rcu() just calls a kfree(), so we
> can use kfree_rcu() instead of call_rcu() + callback function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

net-next is not open yet, please resubmit this when I announce here
on netdev that the net-next tree is open for submissions.

Thank you.
