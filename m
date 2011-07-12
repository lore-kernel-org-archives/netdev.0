From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netdevice: Kill 'feature' test macros.
Date: Tue, 12 Jul 2011 11:10:33 -0700
Message-ID: <20110712111033.6e3923db@nehalam.ftrdhcpuser.net>
References: <20110712.105005.34046159802896038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38709 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754626Ab1GLSKh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 14:10:37 -0400
In-Reply-To: <20110712.105005.34046159802896038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jul 2011 10:50:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Almost all of these have long outstayed their welcome.
> 
> And for every one of these macros, there are 10 features for which we
> didn't get macros added.
> 
> Let's just delete them all, and get out of habit of doing things this
> way.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

This is sure to break out of tree drivers...
