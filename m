From: David Miller <davem@davemloft.net>
Subject: TX multiqueue status...
Date: Wed, 02 Jul 2008 03:33:05 -0700 (PDT)
Message-ID: <20080702.033305.141238860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36336
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751767AbYGBKdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 06:33:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id F168EC8C2F3
	for <netdev@vger.kernel.org>; Wed,  2 Jul 2008 03:33:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


So I have a 34 patch rough draft of my new design sitting here in my
tree.

I think some of it might even work :-)

This is the end of my evening, but tomorrow I plan to respin this
series, do the 3 or 4 line "port" of NIU to support multique, and then
if that tests out alright I'll post what I have.

A lot of the work was going through the tree and saying "what does
this operation mean in a multiqueue environment".
