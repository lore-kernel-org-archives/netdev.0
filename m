From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHES 0/11] skb->mac.raw refactorings
Date: Sun, 11 Mar 2007 20:18:28 -0700 (PDT)
Message-ID: <20070311.201828.21366355.davem@davemloft.net>
References: <39e6f6c70703100845i1ebfdbf7l842511cb8ec8e97@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964952AbXCLDSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 23:18:31 -0400
In-Reply-To: <39e6f6c70703100845i1ebfdbf7l842511cb8ec8e97@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 10 Mar 2007 13:45:44 -0300

> Hi David,
> 
>          Paving the way for turning the layer headers offsets, to
> shrink struct sk_buff on 64bits (and perhaps on 32 bits too).
> 
>          Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22.git

Looks great, pulled, thanks a lot Arnaldo!
