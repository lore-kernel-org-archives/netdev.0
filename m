From: David Miller <davem@davemloft.net>
Subject: Re: [Q] sk->sk_protinfo leftovers
Date: Thu, 25 Jun 2015 06:17:53 -0700 (PDT)
Message-ID: <20150625.061753.966837583367395409.davem@davemloft.net>
References: <CAOJe8K2Vr_79egjdQk=S_SdOcxOR4A0BTORN4ODPMpOwntHUWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, edumazet@google.com
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbFYNF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 09:05:59 -0400
In-Reply-To: <CAOJe8K2Vr_79egjdQk=S_SdOcxOR4A0BTORN4ODPMpOwntHUWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 17 Jun 2015 14:58:15 +0300

> I've found the old thread about removing sk_protinfo member [0]. Back
> in 2005 Ralf mentioned that the ax25 case is more complicated. Have
> the things changed in the ax25 code since  that time?

It's trivial 15 minute hack to remove, I'll post the two patches that do it.
