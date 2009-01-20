From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 5/5] net: pppoe,pppol2tp - register channels with
	explicit net
Date: Wed, 21 Jan 2009 00:58:49 +0300
Message-ID: <20090120215849.GB941@localhost>
References: <20090120140510.228815074@gmail.com>> <4975dc14.0637560a.7f8e.729c@mx.google.com> <49764890.5010403@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org,
	Michal Ostrowski <mostrows@earthlink.net>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:2766 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbZATV65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 16:58:57 -0500
Content-Disposition: inline
In-Reply-To: <49764890.5010403@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[James Chapman - Tue, Jan 20, 2009 at 09:56:32PM +0000]
| Cyrill Gorcunov wrote:
| > In PPPo[E|L2TP] we could explicitly point which net namespace
| > we're going to use for channels - make it so.
| > 
| > CC: James Chapman <jchapman@katalix.com>
| > CC: Michal Ostrowski <mostrows@earthlink.net>
| > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| 
| This one's ok by me too for pppol2tp.
| 
| Signed-off-by: James Chapman <jchapman@katalix.com>
| 

...

| 
| 
| -- 
| James Chapman
| Katalix Systems Ltd
| http://www.katalix.com
| Catalysts for your Embedded Linux software development
| 

Thanks a lot for testing, James! I really appreciate!

		- Cyrill -
