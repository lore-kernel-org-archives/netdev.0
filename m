From: oulijun <oulijun@huawei.com>
Subject: Re: [PATCH 4/4] infiniband: hns: add Hisilicon RoCE support(Kconfig)
Date: Wed, 9 Mar 2016 19:23:41 +0800
Message-ID: <56E007BD.5060902@huawei.com>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
 <1457080877-13456-5-git-send-email-xavier.huwei@huawei.com>
 <20160306142908.GF13396@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>, <dledford@redhat.com>,
	<sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
	<jiri@mellanox.com>, <ogerlitz@mellanox.com>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<yankejian@huawei.com>, <lisheng011@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160306142908.GF13396@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi dledford, thanks your reviewing

On 2016/3/6 22:29, Leon Romanovsky wrote:
> On Fri, Mar 04, 2016 at 04:41:17PM +0800, Wei Hu(Xavier) wrote:
>> This submit add Kconfig.
> 
> It needs be part of previous patch.
We were discussed your review. We will accept it in new patchset.
It will be send soon.

thanks
Lijun Ou
> 
>>
>> Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
>> Signed-off-by: oulijun <oulijun@huawei.com>
> 
> ................^^^^^^^...... -- Is this first name or second name?
> 
>> ---
>>  drivers/infiniband/Kconfig | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
>> index 8a8440c..c7a24bb 100644
>> --- a/drivers/infiniband/Kconfig
>> +++ b/drivers/infiniband/Kconfig
>> @@ -73,7 +73,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
>>  source "drivers/infiniband/hw/nes/Kconfig"
>>  source "drivers/infiniband/hw/ocrdma/Kconfig"
>>  source "drivers/infiniband/hw/usnic/Kconfig"
>> -
>> +source "drivers/infiniband/hw/hisilicon/hns/Kconfig"
>>  source "drivers/infiniband/ulp/ipoib/Kconfig"
>>  
>>  source "drivers/infiniband/ulp/srp/Kconfig"
>> -- 
>> 1.9.1
>>
> 
> .
> 
