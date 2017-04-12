From: "weiyongjun (A)" <weiyongjun1@huawei.com>
Subject: RE: [PATCH net-next] devlink: fix return value check in
 devlink_dpipe_header_put()
Date: Wed, 12 Apr 2017 03:30:25 +0000
Message-ID: <6AADFAC011213A4C87B956458587ADB47B0128@SZXEMI508-MBX.china.huawei.com>
References: <20170410131106.27683-1-weiyj.lk@gmail.com>
 <20170411.230328.1122763321161603727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@mellanox.com" <jiri@mellanox.com>,
        "arkadis@mellanox.com" <arkadis@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5360 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751992AbdDLDaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 23:30:39 -0400
In-Reply-To: <20170411.230328.1122763321161603727.davem@davemloft.net>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, April 12, 2017 11:03 AM
> To: weiyj.lk@gmail.com
> Cc: jiri@mellanox.com; arkadis@mellanox.com; weiyongjun (A)
> <weiyongjun1@huawei.com>; netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] devlink: fix return value check in
> devlink_dpipe_header_put()
> 
> From: Wei Yongjun <weiyj.lk@gmail.com>
> Date: Mon, 10 Apr 2017 13:11:06 +0000
> 
> > From: Wei Yongjun <weiyongjun1@huawei.com>
> >
> > Fix the retrn value check which testing the wrong variable
> > in devlink_dpipe_header_put().
> >
> > Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
> > Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> 
> This doesn't apply cleanly to net-next, please respin and also fix
> the typo in your commit message as pointed out by Jiri.

You have applied the v2 version of this patch some hours ago.  

Regards,
Yongjun Wei
