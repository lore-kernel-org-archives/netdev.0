From: Darren Hart <dvhart@infradead.org>
Subject: Re: [PATCH 00/22] FUJITSU Extended Socket network device driver
Date: Thu, 18 Jun 2015 14:22:10 -0700
Message-ID: <20150618212210.GA121898@vmdeb7>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: platform-driver-x86@vger.kernel.org, rkhan@redhat.com,
	alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 18, 2015 at 09:45:59AM +0900, Taku Izumi wrote:
> This patchsets adds FUJITSU Extended Socket network device driver.
> Extended Socket network device is a shared memory based high-speed network 
> interface between Extended Partitions of PRIMEQUEST 2000 E2 series.
> 
> You can get some information about Extended Partition and Extended
> Socket by referring the following manual.
> 
> http://globalsp.ts.fujitsu.com/dmsp/Publications/public/CA92344-0537.pdf
>  3.2.1 Extended Partitioning
>  3.2.2 Extended Socket
> 

As Alex mentioned earlier, I suspect this is more appropriate for drivers/net.
If David objects, we can consider for platform/drivers/x86.

-- 
Darren Hart
Intel Open Source Technology Center
