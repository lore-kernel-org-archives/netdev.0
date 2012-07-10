From: Christian Franke <nobody@nowhere.ws>
Subject: Re: [PATCH 0/16] Metrics restructuring.
Date: Tue, 10 Jul 2012 18:34:27 +0200
Message-ID: <4FFC5993.4000702@nowhere.ws>
References: <20120710.080703.916560084659556593.davem@davemloft.net> <1341936694.6118.119.camel@joe2Laptop> <20120710.091825.136189827254363527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus.nowhere.ws ([78.111.67.33]:52885 "EHLO zeus.nowhere.ws"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057Ab2GJQea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 12:34:30 -0400
In-Reply-To: <20120710.091825.136189827254363527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2012 06:18 PM, David Miller wrote:
> Is there some voodoo to force a merge commit in what
> would otherwise be a fast-forward?

git merge --no-ff

-Christian
