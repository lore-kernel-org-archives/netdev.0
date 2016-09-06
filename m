From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH -next v2] net: hns: fix return value check in
 hns_dsaf_get_cfg()
Date: Tue, 6 Sep 2016 08:42:25 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6FAE20@lhreml503-mbx>
References: <1467644458-10131-1-git-send-email-weiyj_lk@163.com>
        <1467705412-30194-1-git-send-email-weiyj_lk@163.com>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A6FA0CA@lhreml503-mbx>
 <20160905.124313.2033920102101765222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "weiyj_lk@163.com" <weiyj_lk@163.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "Yankejian (Hackim Yim)" <yankejian@huawei.com>,
        "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:3371 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754196AbcIFImr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 04:42:47 -0400
In-Reply-To: <20160905.124313.2033920102101765222.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, September 05, 2016 8:43 PM
> To: Salil Mehta
> Cc: weiyj_lk@163.com; Zhuangyuzeng (Yisen); Yankejian (Hackim Yim);
> yongjun_wei@trendmicro.com.cn; netdev@vger.kernel.org
> Subject: Re: [PATCH -next v2] net: hns: fix return value check in
> hns_dsaf_get_cfg()
> 
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Mon, 5 Sep 2016 14:20:33 +0000
> 
> > This patch will conflict with Doug Ledford's hns-roce's HNS driver.
> > This might lead to problems later during this merge window of 4.9.
> 
> You don't need to say this three times.
Sorry about this
> 
> These changes will not be reverted, instead the conflicts will need
> to simply be resolved during the merges just like any other conflict
> that ever happens in our trees.
Fine, got your point.
