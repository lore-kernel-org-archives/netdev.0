From: oulijun <oulijun@huawei.com>
Subject: Re: [RESEND PATCH v9 00/22] Add HiSilicon RoCE driver
Date: Mon, 20 Jun 2016 15:29:40 +0800
Message-ID: <57679B64.1060203@huawei.com>
References: <1465368297-82118-1-git-send-email-oulijun@huawei.com>
 <7860e33e-42a0-b98e-116d-45fd32d8acdd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<yankejian@huawei.com>, <charles.chenxin@huawei.com>,
	<linuxarm@huawei.com>
To: Doug Ledford <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:42534 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbcFTHaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 03:30:39 -0400
In-Reply-To: <7860e33e-42a0-b98e-116d-45fd32d8acdd@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/6/8 19:55, Doug Ledford wrote:
> On 6/8/2016 2:44 AM, Lijun Ou wrote:
>> The HiSilicon Network Substem is a long term evolution IP which is
>> supposed to be used in HiSilicon ICT SoCs. HNS (HiSilicon Network
>> Sybsystem) also has a hardware support of performing RDMA with
>> RoCEE.
>> The driver for HiSilicon RoCEE(RoCE Engine) is a platform driver and
>> will support mulitple versions of SOCs in future. This version of driver
>> is meant to support Hip06 SoC(which confirms to RoCEEv1 hardware
>> specifications).
> 
> Please don't resend unless you think the patch has gotten lost.  This is
> a large patchset and takes a considerable deal of time to process.
> 
> That said, I pulled the v9 patchset into my repo in a branch called hns
> yesterday and am doing final review before I accept it into my for-next
> area.
> 
Hi, Doug
  I see. Please forgive my impatience.
  Now, I have sent v10 according to Leon Romanovsky's reviews.

Thanks
Lijun Ou
