From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V3 net-next 5/8] net: hns3: Add support of TX Scheduler &
 Shaper to HNS3 driver
Date: Sun, 23 Jul 2017 08:13:32 +0200
Message-ID: <20170723061332.wiubsmavqemcglmt@localhost.localdomain>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-6-salil.mehta@huawei.com>
 <20170618164518.GA1685@localhost.localdomain>
 <F4CC6FACFEB3C54C9141D49AD221F7F93B81CCAF@FRAEML521-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CCAF@FRAEML521-MBX.china.huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 22, 2017 at 11:38:26PM +0000, Salil Mehta wrote:
> > On Sat, Jun 17, 2017 at 06:24:28PM +0100, Salil Mehta wrote:
> > > +
> > > +int hclge_tm_schd_init(struct hclge_dev *hdev);
> > > +int hclge_tm_setup_tc(struct hclge_dev *hdev);
> > 
> > The definition of this function DNE.
> Sorry, I did not get what DNE means? Does Not Exist ?
> If yes, the I can see the definition of both the functions.

Where in this series is hclge_tm_setup_tc() defined?

Nowhere, AFAICT.

Thanks,
Richard
