From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/27] drivers/net/igb: remove dead code (function
 'igb_read_pci_cfg')
Date: Fri, 26 Dec 2008 00:03:00 -0800 (PST)
Message-ID: <20081226.000300.75987642.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191632.11807.3776.stgit@vmbox.hanneseder.net>
	<9929d2390812221430j1bc15607m58dd07a6ac8dec5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@hanneseder.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752797AbYLZIC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 03:02:58 -0500
In-Reply-To: <9929d2390812221430j1bc15607m58dd07a6ac8dec5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Date: Mon, 22 Dec 2008 14:30:00 -0800

> On Mon, Dec 22, 2008 at 11:16 AM, Hannes Eder <hannes@hanneseder.net> wrote:
> > Fix this warning:
> >
> >  drivers/net/igb/e1000_mac.c:54: warning: 'igb_read_pci_cfg' defined but not used
> >
> > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
 ...
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
