From: Patrick McHardy <kaber@trash.net>
Subject: Re: linux-next: Tree for February 10 (netfilter)
Date: Mon, 14 Feb 2011 08:34:56 +0100
Message-ID: <4D58DB20.5060401@trash.net>
References: <20110210180525.54ec83e9.sfr@canb.auug.org.au> <20110210095210.6fcf3011.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110210095210.6fcf3011.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.02.2011 18:52, Randy Dunlap wrote:
> On Thu, 10 Feb 2011 18:05:25 +1100 Stephen Rothwell wrote:
> 
>> Hi all,
>>
>> [The kernel.org mirroring is being slow ...]
>>
>> Changes since 20110209:
> 
> 
> xt_AUDIT.c:(.text+0x39ca9): undefined reference to `ipv6_skip_exthdr'
> 
> IPV6 is not enabled.
> 
> Full config file is attached.

Thomas, please have a look at this.
