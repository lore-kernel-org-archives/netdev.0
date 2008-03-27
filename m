From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [git patches] net driver updates for .26
Date: Wed, 26 Mar 2008 19:19:05 -0500
Message-ID: <20080326191905.2f96db9b@osprey.hogchain.net>
References: <20080318075902.GA18010@havoc.gtf.org>
	<20080322.183522.124237568.davem@davemloft.net>
	<47E9CBF9.3040700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Snook <csnook@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([207.115.11.55]:49689 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489AbYC0Aa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 20:30:56 -0400
In-Reply-To: <47E9CBF9.3040700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Mar 2008 00:07:21 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> David Miller wrote:
> > From: Jeff Garzik <jeff@garzik.org>
> > Date: Tue, 18 Mar 2008 03:59:02 -0400
[...]
> > There are also some new build warnings such as:
> > 
> > drivers/net/atlx/atl1.c:506: warning: 'atl1_phy_enter_power_saving'
> > defined but not used
> 
> <checks>  doesn't appear in allmodconfig, so it looks like 
> atl1_phy_enter_power_saving() just needs some CONFIG_PM wrappers

I see Dave already added it.  Thanks Dave; sorry for missing it.

Jay

