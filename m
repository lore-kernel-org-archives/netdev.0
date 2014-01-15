From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Route exceptions for IPv6 routes?
Date: Wed, 15 Jan 2014 09:01:22 +0100 (CET)
Message-ID: <trinity-d0560a1c-2418-449e-b478-ebc707cea8e5-1389772882296@3capp-gmx-bs10>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:63277 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbaAOIBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 03:01:23 -0500
Received: from 3capp-gmx-bs10.server.lan ([172.19.170.61]) by
 mrigmx.server.lan (mrigmx002) with ESMTP (Nemesis) id
 0M4USY-1V9LZu2FRc-00ydlm for <netdev@vger.kernel.org>; Wed, 15 Jan 2014
 09:01:22 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I learned that the routing cache was removed from the kernel for several reasons.

Some functions have been replaced with the route exceptions, e.g. storing the path MTU.

My question: is this valid for both IPv4 as well as IPv6 routing, i.e. do the route exceptions work in the same way for IPv6 routes as they work for IPv4 routes?

Maybe a trivial question, but Google didn't give me much information on the topic...

best regards, Simon
