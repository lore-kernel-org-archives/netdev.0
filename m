From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch] cleanup unused macro in net/netlink/af_netlink.c
Date: Fri, 28 Apr 2006 14:59:54 -0700 (PDT)
Message-ID: <20060428.145954.88110275.davem@davemloft.net>
References: <20060428205143.20727.qmail@web36613.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8140
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751632AbWD1V7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 17:59:40 -0400
To: speattle@yahoo.com
In-Reply-To: <20060428205143.20727.qmail@web36613.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: S P <speattle@yahoo.com>
Date: Fri, 28 Apr 2006 13:51:43 -0700 (PDT)

> 1 line removal, of unused macro.
> ran 'egrep -r' from linux-2.6.16/ for Nprintk and
> didn't see it anywhere else but here, in #define...
> 
> ------------------------------------------------
> signed off by: soyoung park<speattle@yahoo.com>

Patch applied, thanks a lot.
