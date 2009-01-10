From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 4/4] net: ppp_generic - introduce net-namespace
	functionality
Date: Sat, 10 Jan 2009 12:22:58 +0300
Message-ID: <20090110092258.GA7622@localhost>
References: <20090109195154.320495476@gmail.com>> <4967accd.0305560a.3553.ffffd187@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:43339 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbZAJJXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 04:23:02 -0500
Content-Disposition: inline
In-Reply-To: <4967accd.0305560a.3553.ffffd187@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cyrill Gorcunov - Fri, Jan 09, 2009 at 10:51:58PM +0300]
| - Each namespace contain ppp channels and units separately
|   with appropriate locks
| 
| CC: Paul Mackerras <paulus@samba.org>
| Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
...

Please ignore this one -- I forgot to update
ppp_init while was porting the patch. Will
fix.

		- Cyrill -
