From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V4 net-next 5/8] net: hns3: Add support of TX Scheduler
 & Shaper to HNS3 driver
Date: Sun, 23 Jul 2017 09:31:46 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81D3AE@FRAEML521-MBX.china.huawei.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-6-salil.mehta@huawei.com>
 <20170723061655.sfwb4ugcprbhkmob@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:32173 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdGWJcB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 05:32:01 -0400
In-Reply-To: <20170723061655.sfwb4ugcprbhkmob@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-
> owner@vger.kernel.org] On Behalf Of Richard Cochran
> Sent: Sunday, July 23, 2017 7:17 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V4 net-next 5/8] net: hns3: Add support of TX
> Scheduler & Shaper to HNS3 driver
> 
> On Sat, Jul 22, 2017 at 11:09:39PM +0100, Salil Mehta wrote:
> > +int hclge_tm_setup_tc(struct hclge_dev *hdev);
> 
> Like I said before, this function DNE.
Sorry, it was removed, I mistakenly saw the old code.
Will remove this prototype as well.

Thanks
Salil
> 
> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
