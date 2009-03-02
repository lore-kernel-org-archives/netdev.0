From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Vlan interface nuisance
Date: Sun, 1 Mar 2009 20:47:31 -0800
Message-ID: <20090301204731.40ce346a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35278 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757579AbZCBEre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 23:47:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Why is interface created through netlink named 'vlan0' and
interface created through old vconfig called 'ethX.YY'.
Seems like the interface should be consistent.
