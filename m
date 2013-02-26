From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter fixes for net
Date: Tue, 26 Feb 2013 17:24:53 -0500 (EST)
Message-ID: <20130226.172453.430508326485431658.davem@davemloft.net>
References: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue, 26 Feb 2013 14:45:18 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Hi David,
> 
> The following patchset contains two bugfixes for netfilter/ipset via
> Jozsef Kadlecsik, they are:
> 
> * Fix timeout corruption if sets are resized, by Josh Hunt.
> 
> * Fix bogus error report if the flag nomatch is set, from Jozsef.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.
