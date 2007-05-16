From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Wed, 16 May 2007 16:00:57 -0700 (PDT)
Message-ID: <20070516.160057.72710956.davem@davemloft.net>
References: <1179066518.15622.60.camel@localhost>
	<1179149418.15622.79.camel@localhost>
	<1179356104.4084.23.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758117AbXEPXAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 19:00:49 -0400
In-Reply-To: <1179356104.4084.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 16 May 2007 18:55:04 -0400

> On Mon, 2007-14-05 at 09:30 -0400, jamal wrote:
> > Incoporating last comments from Patrick.
> > Dave, I think this is ready to apply - against net-2.6 from this
> > morning. 
> 
> Dave - hold onto this patch - Sridhar Samudrala <sri@us.ibm.com> caught
> a bug i need to fix (GSO wont work).

No problems, I'm busy with something else anyways.

> The game starting in a few holds priority for now.

And I can't say whether or not it is related to that :-)
