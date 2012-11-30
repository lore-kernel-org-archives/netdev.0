From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc: RFC: Workaround for problems with lan8710 phy
 auto MDI-X
Date: Fri, 30 Nov 2012 12:23:02 -0500 (EST)
Message-ID: <20121130.122302.1825816242500143123.davem@davemloft.net>
References: <8D7E9026-6276-452B-9E0C-AEB8CF38C9FD@netconsequence.de>
	<alpine.LNX.2.00.1211301622110.25639@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pt@netconsequence.de, otavio@ossystems.com.br, javier@dowhile0.org,
	chohnstaedt@innominate.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jkosina@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1211301622110.25639@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>
Date: Fri, 30 Nov 2012 16:23:30 +0100 (CET)

> Of course it'd be far better if faulty hardware can be autodetected in 
> runtime.

That is how this must be handled.
