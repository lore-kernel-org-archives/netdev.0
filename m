From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: how to set pppoe source mac address?
Date: Sun, 21 Oct 2007 15:33:39 +0200
Message-ID: <005a01c813e6$fdae6610$5267a8c0@Jocke>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:25273 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751360AbXJUNdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 09:33:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have several pppoe i/f's over one eth i/f and I want to set the
source mac address used by each pppoe i/f to a unique mac address from
user space.

Is this possible? If so, how do I do that?

 Jocke

