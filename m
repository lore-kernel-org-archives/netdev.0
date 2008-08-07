From: David Miller <davem@davemloft.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Wed, 06 Aug 2008 20:26:36 -0700 (PDT)
Message-ID: <20080806.202636.246995904.davem@davemloft.net>
References: <20080805155001.GA2526@ami.dom.local>
	<20080806224248.18266k9ahc5nkk8w@hayate.ip6>
	<20080806215258.GA3306@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40201
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753732AbYHGD0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 23:26:35 -0400
In-Reply-To: <20080806215258.GA3306@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I still haven't seen anyone suggest creating a __NET_XMIT_KFREE_SKB to
fix this most rediculious problem.

I'm still waiting...
