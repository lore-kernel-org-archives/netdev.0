From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.19-rc4-git10][PKT_SCHED] sch_htb: INIT_HLIST_NODE
 after hlist_del()
Date: Tue, 07 Nov 2006 14:55:12 -0800 (PST)
Message-ID: <20061107.145512.75430294.davem@davemloft.net>
References: <20061106094449.3b8253b9@freekitty>
	<20061107064943.GA998@ff.dom.local>
	<20061107095007.71c11b47@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44483
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753417AbWKGWzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 17:55:12 -0500
To: shemminger@osdl.org
In-Reply-To: <20061107095007.71c11b47@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 7 Nov 2006 09:50:07 -0800

> Your patch duplicated the code in hlist_del_init().  Why not do:

Indeed, this is the patch I will apply.

Thanks Stephen.
