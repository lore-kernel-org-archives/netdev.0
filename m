From: David Miller <davem@davemloft.net>
Subject: net-2.6 synced with Linus's tree...
Date: Tue, 30 Sep 2008 02:05:56 -0700 (PDT)
Message-ID: <20080930.020556.141307229.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752097AbYI3JGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 05:06:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B0341C8C180
	for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 02:05:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just did a quick sync of net-2.6 with Linus's recent
2.6.27-rc8 release.

I'll start adding bug fixes on top of that, starting
with Herbert's IPSEC+wireless crash fix.
