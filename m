From: David Miller <davem@davemloft.net>
Subject: [Bugme-new, Bug, 12969] New: WARNING: at lib/dma-debug.c:539
 check_sync+0xe9/0x341() (Not tainted)
Date: Sat, 04 Apr 2009 16:49:09 -0700 (PDT)
Message-ID: <20090404.164909.75175000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753041AbZDDXtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 19:49:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Michael, your b44 patch definitely looks correct.

Aplied, thanks!
