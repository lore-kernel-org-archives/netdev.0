From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Tue, 20 Oct 2009 18:23:53 +0400
Message-ID: <20091020142353.GC5181@lenovo>
References: <200910190002.39937.denys@visp.net.lb> <200910201650.10066.denys@visp.net.lb> <20091020135920.GB5181@lenovo> <200910201720.00473.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Ostrowski <mostrows@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:25382 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbZJTOXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 10:23:51 -0400
Content-Disposition: inline
In-Reply-To: <200910201720.00473.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Denys Fedoryschenko - Tue, Oct 20, 2009 at 05:20:00PM +0300]
|
| It panics almost immediately on boot(even on old operations  that was stable, 
| seems on first pppoe customer login attempt), i will rebuild kernel and if 
| interesting will try to get panic message.
| 
...

ok, thanks. I continue digging.
