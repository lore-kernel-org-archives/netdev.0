From: Patrick McHardy <kaber@trash.net>
Subject: Re: synchronous netlink
Date: Fri, 25 Mar 2011 08:53:16 +0100
Message-ID: <4D8C49EC.1060400@trash.net>
References: <20110324.205549.186286411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42361 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab1CYHxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 03:53:15 -0400
In-Reply-To: <20110324.205549.186286411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 25.03.2011 04:55, schrieb David Miller:
> 
> Patrick, just a reminder that we have to deal with that
> connector regression that exists ever since you added code
> to netlink which assumes synchronous processing.

Yes, I didn't get to that yet, sorry. I'm going to take care
of it this weekend.
