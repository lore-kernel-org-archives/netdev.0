From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.26-rc4] fix double call of kfree_skb in
 net/llc/llc_sap.c
Date: Thu, 29 May 2008 03:45:10 -0700 (PDT)
Message-ID: <20080529.034510.89175399.davem@davemloft.net>
References: <84ee89da0805280359mcbc43f0q33f29960af20fba1@mail.gmail.com>
	<20080528201633.GK30251@ghostprotocols.net>
	<84ee89da0805290151o500f1d5bg542f3ee9dff18be6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: dmgenp@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750978AbYE2KpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 06:45:14 -0400
In-Reply-To: <84ee89da0805290151o500f1d5bg542f3ee9dff18be6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Petukhov" <dmgenp@gmail.com>
Date: Thu, 29 May 2008 14:51:59 +0600

> 2008/5/29 Arnaldo Carvalho de Melo <acme@redhat.com>:
> 
> > Good catch, that code needs some revisiting after all these years...
> > Anyway, can you please try this patch and report results?
> 
> problem disappear after patch applied.

Arnaldo, please send the final version of this patch with
proper changelogs and signoffs, thanks!
