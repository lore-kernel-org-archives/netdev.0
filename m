From: Tim Small <tim@buttersideup.com>
Subject: Re: [PATCH] Use firmware provided index to register a network interface
Date: Wed, 22 Sep 2010 23:07:53 +0100
Message-ID: <4C9A7E39.2020304@buttersideup.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20100922183137.GA7607@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Narendra K wrote:
> Hello,
>
> Here is another approach to address the issue of "eth0 does not always
> map to the Integrated NIC Port 1 as denoted on server chassis label".
> For more details please refer to the thread -
> http://marc.info/?l=linux-netdev&m=128163454631618&w=3.
>   


Hi,

Out of interest, that link says that doing it in usespace was rejected,
but doesn't give any references... I'd be interested to know why this
wasn't viable - since this seemed like the best fit at first glance -
most people will never use this, so no need to grow their kernel size
and complexity?

Cheers,

Tim.
