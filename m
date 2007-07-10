From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH re-resend] fix race in AF_UNIX garbage collector
Date: Tue, 10 Jul 2007 10:55:20 -0700 (PDT)
Message-ID: <20070710.105520.30182869.davem@davemloft.net>
References: <E1I8CMY-00053l-00@dorka.pomaz.szeredi.hu>
	<20070710030443.f2deaab6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miklos@szeredi.hu, netdev@vger.kernel.org, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756767AbXGJRy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 13:54:57 -0400
In-Reply-To: <20070710030443.f2deaab6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 10 Jul 2007 03:04:43 -0700

> On Tue, 10 Jul 2007 11:50:30 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > Can you please add this to -mm.  Sometimes that has wonderful effect
> > on the willingness of people to look at a patch.
> 
> sure ;)

Andrew please don't, it's in my "to review" pile.
