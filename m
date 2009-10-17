From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] qlge: Size RX buffers based on MTU.
Date: Sat, 17 Oct 2009 15:37:51 -0700 (PDT)
Message-ID: <20091017.153751.193720868.davem@davemloft.net>
References: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
	<20091016.175142.52482970.davem@davemloft.net>
	<20091017022210.GA14919@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752362AbZJQWh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2009 18:37:29 -0400
In-Reply-To: <20091017022210.GA14919@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Fri, 16 Oct 2009 19:22:10 -0700

> Sorry for the confusion.  I said they were 'interdependent' patches, meaning
> "depending on each other".  I was trying to break this up to
> make it easier to review.  Shall I send it as a single patch?

You should send them as patches that actually compile at each
step of the way and therefore don't break bisection.
