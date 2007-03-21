From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] netlink: no need to crash if table does not exist.
Date: Wed, 21 Mar 2007 11:54:45 +0100
Message-ID: <46010EF5.6010306@trash.net>
References: <20070321104456.GA2637@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39628 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbXCUKy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 06:54:57 -0400
In-Reply-To: <20070321104456.GA2637@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> We would already do that on init.
> Some things become very confused, when nl_table is not used to store
> netlink sockets.


Its unnecessary, but I don't understand what the problem is.
Why would it be NULL and what gets confused?

