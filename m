From: David Miller <davem@davemloft.net>
Subject: net-2.6.25 status...
Date: Mon, 28 Jan 2008 16:20:43 -0800 (PST)
Message-ID: <20080128.162043.168369073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbYA2AU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 19:20:26 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 638DDC8C199
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 16:20:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've been busy here at LCA08 rebasing the net-2.6.25
tree getting it ready for pushing to Linus.

Most of the conflicts were to the usual places, such
as the feature removal schedule text file, things
like drivers/net/{Kconfig,Makefile} etc.

I just send Linus a pull request so if he takes it
then it will show up soon in his tree.

I've powered-on my Niagara boxes back home so I can do
lots of regression builds.
