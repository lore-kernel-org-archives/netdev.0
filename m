From: Peter Stuge <peter@stuge.se>
Subject: Re: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem
	platform
Date: Tue, 15 Jan 2013 01:41:23 +0100
Message-ID: <20130115004123.4525.qmail@stuge.se>
References: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com> <20130112.153533.1713284383322153346.davem@davemloft.net> <1358183953.1713.28.camel@dcbw.foobar.com> <20130114.133412.479351928049237212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dcbw@redhat.com, cpuwolf@gmail.com, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com, bjorn@mork.no,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foo.stuge.se ([212.116.89.98]:45898 "EHLO foo.stuge.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756107Ab3AOAlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 19:41:25 -0500
Content-Disposition: inline
In-Reply-To: <20130114.133412.479351928049237212.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> > should all WWAN drivers be moved to only POINTTOPOINT?
> 
> I can't answer any of your questions unless you tell me what the
> real limitation of these devices is.

It's rather about the network than any given devices, right?


//Peter
