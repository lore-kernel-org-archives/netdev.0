From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: BUG: dst underflow (again)
Date: Fri, 05 Nov 2004 02:34:45 -0500
Message-ID: <418B2D15.5080303@pobox.com>
References: <4178AB0D.6060107@pobox.com>	<20041022.155159.98771450.yoshfuji@linux-ipv6.org>	<20041022075947.GA15795@xi.wantstofly.org>	<1099577717.1039.155.camel@jzny.localdomain>	<20041104221801.584c8f11.davem@davemloft.net>	<418B2645.6080404@pobox.com> <20041104231433.3a7233e8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, buytenh@wantstofly.org, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041104231433.3a7233e8.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Fri, 05 Nov 2004 02:05:41 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
>>I know this question wasn't directed at me, but, I do always compile 
>>ipsec stuff into my kernel, in addition to netfilter.  The relevant 
>>options are attached for the curious.
> 
> 
> Yes, but do you actually install any IPSEC rules into your system?

Unless FC2 initscripts do something weird (I've never configured 
IPSEC...  only the policies that the kernel boots with (presumably the 
null set?).

	Jeff
