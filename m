From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER] nfnetlink: netlink_run_queue() already checks for
 NLM_F_REQUEST
Date: Wed, 21 Mar 2007 13:37:23 +0100
Message-ID: <46012703.8060205@trash.net>
References: <20070321001810.616784269@lsx.localdomain> <20070321001900.748961655@lsx.localdomain> <20070321123304.GV521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41811 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbXCUMh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 08:37:29 -0400
In-Reply-To: <20070321123304.GV521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Patrick has made use of netlink_run_queue() in nfnetlink while my patches
> have been waiting for net-2.6.22 to open. So this check for NLM_F_REQUEST
> can go as well.


Looks good, thanks. I've added it to my queue.
