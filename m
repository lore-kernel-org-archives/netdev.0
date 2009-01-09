From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC 0/4] net namespace for PPP
Date: Fri, 09 Jan 2009 22:51:54 +0300
Message-ID: <4967acca.0437560a.511e.0221@mx.google.com>
Cc: gorcunov@gmail.com, devel@openvz.org, xemul@openvz.org
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:20600 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440AbZAIUAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:00:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

here is a series of RFC in attempt to implement
net-namespaces for PPP protocol (including PPPoE
and PPPoL2TP).

I would really appreciate _any_ kind of comments.
Really doubt if there is no bugs in my implementation
but it's RFC after all. Mostly -compile- tested so it
requires strong review. One more time -- I would admire
any kind of comments (even like -- it's completely broken
and full of sh*t would be fine -- but with details please :).

		Cyrill
-- 
