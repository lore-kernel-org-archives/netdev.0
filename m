From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] Adds options DROPPED PACKETS and LOSS INTERVALS to
 receiver
Date: Fri, 04 Sep 2009 05:42:02 -0700 (PDT)
Message-ID: <20090904.054202.35826460.davem@davemloft.net>
References: <1252067108.6172.4.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: ivocalado@embedded.ufcg.edu.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57978
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756773AbZIDMlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 08:41:47 -0400
In-Reply-To: <1252067108.6172.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Fri, 04 Sep 2009 09:25:08 -0300

> 
> /* return 1 if a new loss event has been identified */
> -static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff
> *skb, u32 n3)
> +static int __two_after_loss(struct tfrc_rx_hist *h,
> +     struct sk_buff *skb, u32 n3,

Your patches are all heavily corrupted by your email client.

As seen here, long lines are chopped up with newlines, and also tab
characters have been changed into sequences of spaces.

Please fix this up and submit your patches properly.  Use
Documentation/email-clients.txt to learn how to fix these problems.

Thank you.
