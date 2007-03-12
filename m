From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHES 00/18] skb->nh refactorings
Date: Mon, 12 Mar 2007 14:22:01 -0700 (PDT)
Message-ID: <20070312.142201.95061435.davem@davemloft.net>
References: <39e6f6c70703112126g16f8c82aq945436f5f3008eeb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752581AbXCLVWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 17:22:02 -0400
In-Reply-To: <39e6f6c70703112126g16f8c82aq945436f5f3008eeb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 12 Mar 2007 01:26:18 -0300

>           Paving the way for turning the layer headers offsets, to
> shrink struct sk_buff on 64bits (and perhaps on 32 bits too), this
> time for skb->nh, more on this layer still to come (ip_hdr(), etc).
> 
>           Please consider pulling from:
> 
> master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.22.git

Pulled, thanks Arnaldo.
