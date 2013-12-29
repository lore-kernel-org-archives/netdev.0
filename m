From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] Netfilter/IPVS fixes for net
Date: Sun, 29 Dec 2013 00:29:50 -0500 (EST)
Message-ID: <20131229.002950.956841716132299134.davem@davemloft.net>
References: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 28 Dec 2013 23:02:59 +0100

> This patchset contains four nf_tables fixes, one IPVS fix due to
> missing updates in the interaction with the new sedadj conntrack
> extension that was added to support the netfilter synproxy code,
> and a couple of one-liners to fix netnamespace netfilter issues.
> More specifically, they are:
  ...
> We don't usually have this amount of fixes by this time (as we're already
> in -rc5 of the development cycle), although half of them are related to
> nf_tables which is a relatively new thing, and I also belive that holidays
> have also delayed the flight of bugfixes to mainstream a bit.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.

> P.S: Have a nice entrance to new year.

Same to you. :)
