From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 0/4] net namespace for PPP
Date: Sat, 10 Jan 2009 00:32:41 +0300
Message-ID: <20090109213241.GE11646@localhost>
References: <4967acca.0437560a.511e.0221@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f29.google.com ([209.85.218.29]:63024 "EHLO
	mail-bw0-f29.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbZAIVco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:32:44 -0500
Content-Disposition: inline
In-Reply-To: <4967acca.0437560a.511e.0221@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cyrill Gorcunov - Fri, Jan 09, 2009 at 10:51:54PM +0300]
| Hi,
| 
| here is a series of RFC in attempt to implement
| net-namespaces for PPP protocol (including PPPoE
| and PPPoL2TP).
| 
| I would really appreciate _any_ kind of comments.
| Really doubt if there is no bugs in my implementation
| but it's RFC after all. Mostly -compile- tested so it
| requires strong review. One more time -- I would admire
| any kind of comments (even like -- it's completely broken
| and full of sh*t would be fine -- but with details please :).
| 
| 		Cyrill
| -- 
| 

Ah, forgot to mention the patches are over the
net-next-2.6 tree commit

commit 6332178d91ca1a9dbd99bd97cabbcf965d178e9f
Merge: 908a7a1... 739840d...
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Dec 23 17:56:23 2008 -0800

		- Cyrill -
