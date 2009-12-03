From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC] sk_nulls_next_rcu
Date: Fri, 4 Dec 2009 00:47:02 +0200
Message-ID: <200912040047.02539.opurdila@ixiacom.com>
References: <200912010219.29340.opurdila@ixiacom.com> <20091201005929.GB21463@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:25217 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751772AbZLCWuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 17:50:10 -0500
In-Reply-To: <20091201005929.GB21463@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 01 December 2009 02:59:29 you wrote:
> Em Tue, Dec 01, 2009 at 02:19:29AM +0200, Octavian Purdila escreveu:
> > I am trying to convert the LLC code to RCU, and it appears that for proc
> > support a sk_nulls_next_rcu would be required.
> 
> I find it amusing, and give you a carte blanche on that! :-)
> 

:-) Its just an exercise for me to understand RCU, but its harder than I 
originally thought and I did give up trying to finish it in the first batch of 
LLC patches I've just sent.

