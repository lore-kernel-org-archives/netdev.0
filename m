From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 4/6] smsc911x: convert ap325rxa platform to use smsc911x
Date: Fri, 21 Nov 2008 16:46:03 +0900
Message-ID: <20081121074603.GA26397@linux-sh.org>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com> <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com> <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com> <1225881342-3485-4-git-send-email-steve.glendinning@smsc.com> <1225881342-3485-5-git-send-email-steve.glendinning@smsc.com> <49266715.9090705@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, catalin.marinas@arm.com,
	Bahadir.Balban@arm.com, dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Linux-sh <linux-sh@vger.kernel.org>
To: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta23.gyao.ne.jp ([125.63.38.249]:29310 "EHLO mx.gate01.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752293AbYKUHrb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 02:47:31 -0500
Content-Disposition: inline
In-Reply-To: <49266715.9090705@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 04:45:25PM +0900, Nobuhiro Iwamatsu wrote:
> Steve Glendinning wrote:
> > Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> > ---
> >  arch/sh/boards/board-ap325rxa.c    |   24 +++++++++++++-----------
> >  arch/sh/configs/ap325rxa_defconfig |   21 +++++++++++++++++++--
> >  2 files changed, 32 insertions(+), 13 deletions(-)
> 
> Tested-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>

Acked-by: Paul Mundt <lethal@linux-sh.org>
