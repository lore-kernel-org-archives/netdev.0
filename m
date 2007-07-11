From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make all initialized struct seq_operations const
Date: Tue, 10 Jul 2007 23:12:22 -0700 (PDT)
Message-ID: <20070710.231222.38712982.davem@davemloft.net>
References: <20070706132543.GA13101@muff.macqel.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phdm@macqel.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52106
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759722AbXGKGMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 02:12:00 -0400
In-Reply-To: <20070706132543.GA13101@muff.macqel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe De Muyter <phdm@macqel.be>
Date: Fri, 6 Jul 2007 15:25:43 +0200

> Make all initialized struct seq_operations in net/ const
> 
> Signed-off-by: Philippe De Muyter <phdm@macqel.be>

Applied, thanks a lot.
