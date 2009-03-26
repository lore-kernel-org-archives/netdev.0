From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 26 Mar 2009 16:47:38 +0100
Message-ID: <49CBA39A.4000705@trash.net>
References: <20090326141405.GA25404@ioremap.net> <49CB8EC6.6070705@trash.net> <20090326145946.GA28563@ioremap.net> <49CB9A57.6030903@trash.net> <20090326154135.GA30712@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326154135.GA30712@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Mar 26, 2009 at 04:08:07PM +0100, Patrick McHardy (kaber@trash.net) wrote:
>> nfnetlink also supports notifications. Please get rid of this,
>> it should be no problem to resurrect the necessary parts later
>> if this is desired.
> 
> Ok, patch below does not contain it.

Thanks. I'll wait for Dave's decision before applying it.
