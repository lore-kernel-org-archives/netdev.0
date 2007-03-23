From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: SAD sometimes has double SAs.
Date: Fri, 23 Mar 2007 16:27:46 -0700 (PDT)
Message-ID: <20070323.162746.48528766.davem@davemloft.net>
References: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eparis@redhat.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@trustedcs.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934334AbXCWX2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 19:28:01 -0400
In-Reply-To: <200703232258.l2NMwKqH016994@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Fri, 23 Mar 2007 16:58:20 -0600

> Last Friday I proposed creating larval SAs to act as
> placeholders to prevent a second acquire resulting in 
> double SAs being created. 
> I tried this and so far I have not seen any double SAs
> being created. I also plan to run some stress tests over 
> the weekend.
> 
> Please let me know what improvements I can make to this patch or
> if there is a better way to do this.

I'll take a look at your patch after I deal with some ipv6
locking bugs, thanks Joy.
