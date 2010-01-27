From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 03:04:16 -0800 (PST)
Message-ID: <20100127.030416.179345234.davem@davemloft.net>
References: <20100127095952.GA11635@ff.dom.local>
	<20100127.021424.263649631.davem@davemloft.net>
	<20100127103417.GA15206@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159Ab0A0LEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 06:04:04 -0500
In-Reply-To: <20100127103417.GA15206@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 27 Jan 2010 10:34:17 +0000

> (Btw, maybe it's a sign this might be more readable?)

I welcome suggests that, tree wide, would make this harder
to misinterpret.
