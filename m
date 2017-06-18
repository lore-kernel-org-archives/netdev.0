From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V3 net-next 5/8] net: hns3: Add support of TX Scheduler &
 Shaper to HNS3 driver
Date: Sun, 18 Jun 2017 18:45:18 +0200
Message-ID: <20170618164518.GA1685@localhost.localdomain>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-6-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34941 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdFRQpY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 12:45:24 -0400
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-6-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 17, 2017 at 06:24:28PM +0100, Salil Mehta wrote:
> +
> +int hclge_tm_schd_init(struct hclge_dev *hdev);
> +int hclge_tm_setup_tc(struct hclge_dev *hdev);

The definition of this function DNE.

> +int hclge_pause_setup_hw(struct hclge_dev *hdev);
> +
> +#endif
> -- 
> 2.7.4

Thanks,
Richard
