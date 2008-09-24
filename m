From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: AIM9 regression
Date: Wed, 24 Sep 2008 14:10:54 -0500
Message-ID: <48DA90BE.5090208@linux-foundation.org>
References: <48D93203.2050204@linux-foundation.org>	<20080924051237.GA6173@gondor.apana.org.au>	<20080923.221831.126801015.davem@davemloft.net> <20080924081603.08a5f808@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44330 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751672AbYIXTMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 15:12:10 -0400
In-Reply-To: <20080924081603.08a5f808@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> These loopback benchmarks are often more sensitive to scheduler than networking
> changes.

Just ran a test with real NICs which show the same issues. I guess I need to
get familiar with the network stack and start hacking on it. Sigh.


