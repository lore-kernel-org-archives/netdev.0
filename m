From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] qla3xxx: remove unused variable in
 ql_process_mac_tx_intr()
Date: Wed, 31 Oct 2012 13:36:16 -0400 (EDT)
Message-ID: <20121031.133616.1875781845378616423.davem@davemloft.net>
References: <CAPgLHd-rHiLuMR45R7uDWx=BVNr01XpcG6XG0_uMwjbhUGyKEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, ron.mercer@qlogic.com,
	yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933316Ab2JaRgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 13:36:22 -0400
In-Reply-To: <CAPgLHd-rHiLuMR45R7uDWx=BVNr01XpcG6XG0_uMwjbhUGyKEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Fri, 26 Oct 2012 23:30:31 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable retval is initialized but never used
> otherwise, so remove the unused variable.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
