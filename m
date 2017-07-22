From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V3 net-next 5/8] net: hns3: Add support of TX Scheduler
 & Shaper to HNS3 driver
Date: Sat, 22 Jul 2017 23:38:26 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CCAF@FRAEML521-MBX.china.huawei.com>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-6-salil.mehta@huawei.com>
 <20170618164518.GA1685@localhost.localdomain>
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
        Linuxarm <linuxarm@huawei.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170618164518.GA1685@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Sunday, June 18, 2017 5:45 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V3 net-next 5/8] net: hns3: Add support of TX
> Scheduler & Shaper to HNS3 driver
> 
> On Sat, Jun 17, 2017 at 06:24:28PM +0100, Salil Mehta wrote:
> > +
> > +int hclge_tm_schd_init(struct hclge_dev *hdev);
> > +int hclge_tm_setup_tc(struct hclge_dev *hdev);
> 
> The definition of this function DNE.
Sorry, I did not get what DNE means? Does Not Exist ?
If yes, the I can see the definition of both the functions.

Best regards
Salil
> 
> > +int hclge_pause_setup_hw(struct hclge_dev *hdev);
> > +
> > +#endif
> > --
> > 2.7.4
> 
> Thanks,
> Richard
