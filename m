From: Andi Kleen <andi@firstfloor.org>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 22:34:14 +0200
Message-ID: <20100414203414.GT18855@one.firstfloor.org>
References: <1265568122.3688.36.camel@bigi> <65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com> <1265641748.3688.56.camel@bigi> <1271245986.3943.55.camel@bigi> <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com> <1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi> <20100414124426.6aee95c3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53552 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756260Ab0DNUeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 16:34:18 -0400
Content-Disposition: inline
In-Reply-To: <20100414124426.6aee95c3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> RPS might also interact with the core turbo boost functionality on Intel chips.
> Newer chips will make a single core faster if other core can be kept idle.

In addition to Turbo using less cores can also help to save power.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
