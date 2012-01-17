From: David Miller <davem@davemloft.net>
Subject: Re: /proc/net/tcp6 inconsistent line length
Date: Tue, 17 Jan 2012 09:29:19 -0500 (EST)
Message-ID: <20120117.092919.256154724054543177.davem@davemloft.net>
References: <20120117152919.7746a3f9@wwwwww-701SD>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: abirvalg@lavabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab2AQO3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 09:29:22 -0500
In-Reply-To: <20120117152919.7746a3f9@wwwwww-701SD>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <abirvalg@lavabit.com>
Date: Tue, 17 Jan 2012 15:29:19 +0000

> My application relies heavily on the constant number of chars in a line of /proc/net/tcp* files

Too bad, parse the fields properly.
