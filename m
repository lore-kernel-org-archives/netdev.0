From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 being rebased...
Date: Tue, 03 Jun 2008 14:28:25 -0700 (PDT)
Message-ID: <20080603.142825.136645599.davem@davemloft.net>
References: <20080603.142407.08652094.davem@davemloft.net>
	<396556a20806031427j4e8c793fl4be394a5c145325e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linville@tuxdriver.com
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43844
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752416AbYFCV20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:28:26 -0400
In-Reply-To: <396556a20806031427j4e8c793fl4be394a5c145325e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Tue, 3 Jun 2008 14:27:34 -0700

> On Tue, Jun 3, 2008 at 2:24 PM, David Miller <davem@davemloft.net> wrote:
> > Because of the bugs in Adam's MD5/SACK fix I need to rebase
> > the tree to get rid of it.  Adam, please post a complete
> > new patch once you've fixed that SACK option adding problem.
> > Thanks.
> 
> I'm just finishing up a proposed fix if you want to hold off.

It's better to have only a working fix in there.  But thanks anyways.
