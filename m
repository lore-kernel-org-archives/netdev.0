From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Thu, 22 Feb 2007 10:24:11 -0800
Message-ID: <20070222102411.32a93df3@freekitty>
References: <20070222121427.GA29455@2ka.mipt.ru>
	<20070222.053138.74748069.davem@davemloft.net>
	<20070222134620.GC5208@2ka.mipt.ru>
	<20070222.060805.59465933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60036 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbXBVSY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 13:24:26 -0500
In-Reply-To: <20070222.060805.59465933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> BTW, there was a query about this back in Feb. 2006 on linux-kernel,
> nobody replied, he reposted to linux-net in September 2006 and this
> is likely where this kernel bugzilla comes from :-)
> 
> This is not a kernel bug, let's close this and move on.

Agreed closed

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
