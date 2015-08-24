From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 00/22] FUJITSU Extended Socket network device driver
Date: Mon, 24 Aug 2015 14:10:32 -0700 (PDT)
Message-ID: <20150824.141032.405416417791540419.davem@davemloft.net>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	dvhart@infradead.org, rkhan@redhat.com,
	alexander.h.duyck@redhat.com, linux-acpi@vger.kernel.org,
	joe@perches.com, sergei.shtylyov@cogentembedded.com,
	stephen@networkplumber.org, yasu.isimatu@gmail.com
To: izumi.taku@jp.fujitsu.com
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Fri, 21 Aug 2015 17:28:00 +0900

> This patchsets adds FUJITSU Extended Socket network device driver.
> Extended Socket network device is a shared memory based high-speed
> network interface between Extended Partitions of PRIMEQUEST 2000 E2
> series.
> 
> You can get some information about Extended Partition and Extended
> Socket by referring the following manual.
> 
> http://globalsp.ts.fujitsu.com/dmsp/Publications/public/CA92344-0537.pdf
>     3.2.1 Extended Partitioning
>     3.2.2 Extended Socke
> 
> v2.2 -> v3:
>    - Fix up according to David's comment (No functional change)

Series applied, thank you.
