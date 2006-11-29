From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely   duplicate route_reverse function
Date: Wed, 29 Nov 2006 08:35:05 +0100
Message-ID: <20061129073505.GB1001@ff.dom.local>
References: <20061128.202535.112619392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:16041 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S935416AbWK2H22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 02:28:28 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061128.202535.112619392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29-11-2006 05:25, David Miller wrote:
...
> commit 93e3a20d6c67a09b867431e7d5b3e7bc97154fab
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Tue Nov 28 20:24:10 2006 -0800
> 
>     [NET]: Fix MAX_HEADER setting.
>     
>     MAX_HEADER is either set to LL_MAX_HEADER or LL_MAX_HEADER + 48, and
>     this is controlled by a set of CONFIG_* ifdef tests.
...
>     Noticed by Patrick McHardy.

And if we talk about names:

+ Spotted by Krzysztof Halasa.

probably wouldn't be too exaggerated...

>     Signed-off-by: David S. Miller <davem@davemloft.net>

Jarek P.
