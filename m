From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] vxlan: fix some sparse warnings
Date: Fri, 12 Apr 2013 15:03:21 -0400 (EDT)
Message-ID: <20130412.150321.123271678963283612.davem@davemloft.net>
References: <CAPgLHd_utCxvQJtACgTqL2cMJBV74Xw6x0iOgJvbN+Qej6c8-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com,
	alexander.h.duyck@intel.com, dlstevens@us.ibm.com,
	zealot0630@gmail.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab3DLTDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 15:03:23 -0400
In-Reply-To: <CAPgLHd_utCxvQJtACgTqL2cMJBV74Xw6x0iOgJvbN+Qej6c8-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 12 Apr 2013 13:00:35 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fixes following warning:
> drivers/net/vxlan.c:406:6: warning: symbol 'vxlan_fdb_free' was not declared. Should it be static?
> drivers/net/vxlan.c:1111:37: warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
