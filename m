From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/13] net: hns: add support of ACPI
Date: Fri, 03 Jun 2016 19:49:51 -0400 (EDT)
Message-ID: <20160603.194951.1703111522316735768.davem@davemloft.net>
References: <1464922521-30928-1-git-send-email-Yisen.Zhuang@huawei.com>
	<3949626.e0mVHh16br@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yisen.Zhuang@huawei.com, lenb@kernel.org, fengguang.wu@intel.com,
	andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
	ivecera@redhat.com, f.fainelli@gmail.com, haifeng.wei@huawei.com,
	charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linuxarm@huawei.com
To: rjw@rjwysocki.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3949626.e0mVHh16br@vostro.rjw.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Fri, 03 Jun 2016 23:34:50 +0200

> On Friday, June 03, 2016 10:55:08 AM Yisen Zhuang wrote:
>> From: Kejian Yan <yankejian@huawei.com>
 ...
>> Kejian Yan (13):
>>   ACPI: bus: add stub acpi_dev_found() to linux/acpi.h
>>   ACPI: bus: add stub acpi_evaluate_dsm() to linux/acpi.h
> 
> Which patches need these stubs?

10 and 12
