From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [v2 8/9] dpaa_eth: add debugfs entries
Date: Tue, 11 Aug 2015 11:00:39 +0000
Message-ID: <BL2PR03MB545A863C210E5BFC9DFC128E67F0@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1438789289-16304-1-git-send-email-madalin.bucur@freescale.com>
	<1438789289-16304-9-git-send-email-madalin.bucur@freescale.com>
 <20150807.153716.1393797980617992919.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Liberman Igal <Igal.Liberman@freescale.com>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"joe@perches.com" <joe@perches.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0104.outbound.protection.outlook.com ([207.46.100.104]:53297
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932862AbbHKLAn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 07:00:43 -0400
In-Reply-To: <20150807.153716.1393797980617992919.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Madalin Bucur <madalin.bucur@freescale.com>
> Date: Wed, 5 Aug 2015 18:41:28 +0300
> 
> > Export per CPU counters through debugfs.
> >
> > Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> 
> This is absolutely inappropriate.
> 
> You can export these just fine via ethtool statistics.  There is zero reason
> to add ugly debugfs crap for something like this.

If you have such a strong adversity about the debugfs, then I'll export these
debug counters through ethtool statistics in the next version.

Madalin
