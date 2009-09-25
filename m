From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: ks8851 ethernet network driver - RESUBMIT
Date: Fri, 25 Sep 2009 12:09:47 -0700 (PDT)
Message-ID: <20090925.120947.24952563.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D02127B@MELANITE.micrel.com>
	<20090924.163941.156434226.davem@davemloft.net>
	<C43529A246480145B0A6D0234BDB0F0D02127E@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org, Charles.Li@Micrel.Com,
	Choi@kroah.com, jgarzik@redhat.com, shemminger@vyatta.com
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751676AbZIYTJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 15:09:28 -0400
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D02127E@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch does not apply.

There is already a CONFIG_KS8851 and a drivers/net/ks8851.c driver
in Linus's tree right now.  So it completely conflicts with your's

I'm getting burnt out going back and forth trying to apply this
patch and it doesn't apply cleanly or there's already a driver
with that name etc.

This is a complete mess and a very poor driver submission.

Please get things straight, look at how other developers write
their commit messages and signoffs (your's was in bad style and
the signoff was not in the format described in
linux/Documentation/SubmittingPatches, for example).
