From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: linux-next: Tree for Mar 9 (netfilter)
Date: Sat, 10 Mar 2012 08:45:22 -0800
Message-ID: <4F5B8522.8050707@xenotime.net>
References: <20120309191101.8634973f7d9988c602143f7c@canb.auug.org.au> <4F5A6872.3050502@xenotime.net> <20120310112154.GA22478@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120310112154.GA22478@1984>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2012 03:21 AM, Pablo Neira Ayuso wrote:

> On Fri, Mar 09, 2012 at 12:30:42PM -0800, Randy Dunlap wrote:
>> On 03/09/2012 12:11 AM, Stephen Rothwell wrote:
>>
>>> Hi all,
>>>
>>> There will be no linux-next release on March 12 due to a public holiday.
>>>
>>> Changes since 20120308:
>>
>>
>> xt_LOG.c:(.text+0x789b1): undefined reference to `ip6t_ext_hdr'
>>
>> Full randconfig file is attached.
> 
> The patch attached fixes this problem, thanks!


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

-- 
~Randy
