From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.9 conntrack performance issues
Date: Mon, 30 Jan 2017 13:37:43 +0200
Message-ID: <c18a30d1b61b758e8de93ea373247da7@nuclearcat.com>
References: <1a71d807acf63135bb037c7144fcd8d9@nuclearcat.com>
 <20170130112630.pl2jdegnaydxxdpg@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Devel <netfilter-devel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170130112630.pl2jdegnaydxxdpg@alphalink.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-30 13:26, Guillaume Nault wrote:
> On Sun, Jan 15, 2017 at 01:05:58AM +0200, Denys Fedoryshchenko wrote:
>> Hi!
>> 
>> Sorry if i added someone wrongly to CC, please let me know, if i 
>> should
>> remove.
>> I just run successfully 4.9 on my nat several days ago, and seems 
>> panic
>> issue disappeared.
>> 
> Hi Denys,
> 
> After two weeks running Linux 4.9, do you confirm that the original
> issue[1] is gone?
> 
> Regards,
> 
> Guillaume
> 
> [1]: https://www.spinics.net/lists/netdev/msg410795.html
Yes, no more reboots at all and 4.9 patched for gc issues seems 
significantly better for NAT performance (CPU load lower almost twice 
than previous kernels, i dont have exact numbers).
