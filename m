From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: using per-socket ipsec policies as user
Date: Sun, 11 Nov 2012 07:21:55 +0100
Message-ID: <20121111062155.GB28043@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46613 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721Ab2KKGV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 01:21:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list and Steffen,

in commit 6fc0b4a xfrm policy loading via setsockopt was restricted to CAP_NET_ADMIN. I
wondered if the situation of the xfrm interface got better since then or what
needs to be done to remove this restriction.

Greetings,

  Hannes
