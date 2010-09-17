From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 0/5]qlcnic: vlan rx accleration support
Date: Fri, 17 Sep 2010 11:31:44 -0700 (PDT)
Message-ID: <20100917.113144.73363164.davem@davemloft.net>
References: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754452Ab0IQSbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 14:31:25 -0400
In-Reply-To: <1284700483-16397-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Thu, 16 Sep 2010 22:14:38 -0700

> Hi
>   Series v2 of 5 patches to support vlan rx accleration.
>   This takes care of Eric Dumazet comment of using dev_kfree_skb(skb).
>  
>   I haven't combined accleration and GRO patch. Though its look strange
>   with first patch. But I want to have separate patches for two different 
>   entity.

All applied, thanks.
