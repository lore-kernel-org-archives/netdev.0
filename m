From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: xt_nat_init: BUG: unable to handle kernel NULL pointer
 dereference at 00000000000000e0
Date: Thu, 13 Sep 2012 18:55:10 +0800
Message-ID: <20120913105510.GA31666@localhost>
References: <20120913091629.GA28022@localhost>
 <1347528823.13103.1427.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	networking <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Netfilter Development Maili..." <netfilter-devel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347528823.13103.1427.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Wasnt it already solved ?
> 
> http://1984.lsi.us.es/git/nf-next/commit/?id=00545bec9412d130c77f72a08d6c8b6ad21d4a1
> 
> Just have to wait that netfilter fixes are pushed upstream

OK, sorry. I didn't subscribe many mailing lists and rely on the
search results in google and LKML to avoid duplicate reports..

Thanks,
Fengguang
