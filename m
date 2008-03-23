From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: kernel panic, ip_route_input, 2.6.25-rc6-git2 (was lockdep... )
Date: Sun, 23 Mar 2008 09:36:38 +0200
Message-ID: <20080323073638.M89709@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:34767 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbYCWHgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 03:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently tested, it crashes also -git6 without lockdep compiled. So it seems 
actually networking code bug.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

