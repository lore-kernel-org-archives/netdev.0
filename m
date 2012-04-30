From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] netfilter updates for 3.4-rc5
Date: Mon, 30 Apr 2012 13:23:54 -0400 (EDT)
Message-ID: <20120430.132354.1636633057674161055.davem@davemloft.net>
References: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335799015-2003-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Mon, 30 Apr 2012 17:16:47 +0200

> This patchset contains the following fixes:
> 
> * One fix in the initialization path of the IPVS modules spotted by
>   the the trinity syscall fuzz testing tool from Sasha Levin.
> 
> * Three patches to address more weak/buggy error handling in the
>   initialization path of the IPVS modules from Hans Schillinstrom.
> 
> * Fix a regression in the initialization path of ipvs_ctl (introduced in
>   2.6.39) due from Julian Anastasov.
> 
> * A couple more initialization path robust error checkings from Julian
>   Anastasov.
> 
> * One silly fix for xt_CT target for the case in which the new
>   cttimeout infrastructure is not used, eg. --helper or --notrack,
>   by myself.
> 
> You can pull these fixes from:
> 
> git://1984.lsi.us.es/net master

Pulled, thanks Pablo.
