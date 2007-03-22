From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] [PATCHSET] netlink error management
Date: Thu, 22 Mar 2007 14:05:24 -0700 (PDT)
Message-ID: <20070322.140524.41657535.davem@davemloft.net>
References: <20070321231801.342849239@lsx.localdomain>
	<20070322.122355.48516149.davem@davemloft.net>
	<20070322195754.GZ521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752320AbXCVVFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 17:05:24 -0400
In-Reply-To: <20070322195754.GZ521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 22 Mar 2007 20:57:54 +0100

> * David Miller <davem@davemloft.net> 2007-03-22 12:23
> > From: Thomas Graf <tgraf@suug.ch>
> > Date: Thu, 22 Mar 2007 00:18:01 +0100
> > 
> > > This series of patches simplifies the error management and
> > > signalization of dump starts of netlink_run_queue() message
> > > handlers. It touches a fair bit of nfnetlink code as the
> > > error pointer has been passed on to subsystems.
> > 
> > Thomas can you respin these patches?  They no longer apply
> > now that I put your other rtnl_link bits into net-2.6.22
> 
> I guess I've posted too many patches series, the patches should
> still apply, at least it works in my quilt tree, but depend on
> others. The series I've posted in the correct order are:

It doesn't, that's why I asked you to respin.

Perhaps "patch" would allow them with some fuzz, but git
definitely doesn't want to apply it.
