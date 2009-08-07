From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 0/7] AlacrityVM guest drivers Reply-To:
Date: Fri, 07 Aug 2009 09:19:17 -0500
Message-ID: <4A7C37E5.4040302@codemonkey.ws>
References: <20090803171030.17268.26962.stgit@dev.haskins.net> <20090806081955.GA9752@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090806081955.GA9752@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin wrote:
>
>> This series includes the basic plumbing, as well as the driver for
>> accelerated 802.x (ethernet) networking.
>>     
>
> The graphs comparing virtio with vbus look interesting.
>   

1gbit throughput on a 10gbit link?  I have a hard time believing that.

I've seen much higher myself.  Can you describe your test setup in more 
detail?

Regards,

Anthony Liguori
