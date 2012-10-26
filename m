From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [PATCH -next] qla3xxx: remove unused variable in
 ql_process_mac_tx_intr()
Date: Fri, 26 Oct 2012 09:35:21 -0700
Message-ID: <5E4F49720D0BAD499EE1F01232234BA87744C0BAC5@AVEXMB1.qlogic.org>
References: <CAPgLHd-rHiLuMR45R7uDWx=BVNr01XpcG6XG0_uMwjbhUGyKEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:40515
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965301Ab2JZQf1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 12:35:27 -0400
In-Reply-To: <CAPgLHd-rHiLuMR45R7uDWx=BVNr01XpcG6XG0_uMwjbhUGyKEw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>From: Wei Yongjun [mailto:weiyj.lk@gmail.com] 
>Sent: Friday, October 26, 2012 8:31 AM
>To: Jitendra Kalsaria; Ron Mercer
>Cc: yongjun_wei@trendmicro.com.cn; Dept-Eng Linux Driver; netdev
>Subject: [PATCH -next] qla3xxx: remove unused variable in ql_process_mac_tx_intr()
>
>From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
>The variable retval is initialized but never used
>otherwise, so remove the unused variable.
>
>dpatch engine is used to auto generate this patch.
>(https://github.com/weiyj/dpatch)
>
>Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
