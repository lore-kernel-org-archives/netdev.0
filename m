From: Parav Pandit <pandit.parav@gmail.com>
Subject: Re: [PATCH 3/4] infiniband: hns: add Hisilicon RoCE support(driver code)
Date: Mon, 14 Mar 2016 23:50:25 +0530
Message-ID: <CAG53R5UTc8xF4TdRJm3ASv6PQ-JxhW7vDgXpFtYqX2tz_58UeA@mail.gmail.com>
References: <CAG53R5WfQR1jJUOi1fjY=oEgsK_EAxkA9SiDPV_KHLHsmqg0BQ@mail.gmail.com>
	<56E65EFC.3030109@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>,
	Doug Ledford <dledford@redhat.com>,
	"Hefty, Sean" <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: oulijun <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E65EFC.3030109@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>
>> Since SRQ is not supported in this driver version, can you keep
>> remaining code base also to not bother about SRQ specifically
>> poll_cq_one, modify_qp, destroy_qp etc?
>> SRQ support can come as complete additional patch along with cmd_mask,
>> callbacks and rest of the code.
>>
>> .
> Sorry, I see your review in time.
> Sure, SRQ is not supported in current roce driver. I have verified the function
> for RDMA. It is not influence. For your question, we need to analyse it scientific.
> after that, i will reply your doubt, is that ok?

Yes. No problem.
