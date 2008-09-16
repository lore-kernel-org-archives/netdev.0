From: David Miller <davem@davemloft.net>
Subject: nvidia driver fix
Date: Tue, 16 Sep 2008 15:38:05 -0700 (PDT)
Message-ID: <20080916.153805.83330716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50035
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750884AbYIPWiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 18:38:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jeff please make sure the following makes it's way into
your next bug fix pull request to me as it's fixes
a regression list entry:

http://marc.info/?l=linux-kernel&m=121894416718874&w=4

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11358
Subject		: net: forcedeth call restore mac addr in nv_shutdown path
Submitter	: Yinghai Lu <yhlu.kernel@gmail.com>
Date		: 2008-08-17 3:30 (27 days old)
References	: http://marc.info/?l=linux-kernel&m=121894389018584&w=4
Handled-By	: Yinghai Lu <yhlu.kernel@gmail.com>
Patch		: http://marc.info/?l=linux-kernel&m=121894389018584&w=4

