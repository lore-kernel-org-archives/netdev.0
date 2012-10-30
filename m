From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 6/8] tun: implement byte queue limits
Date: Mon, 29 Oct 2012 18:09:48 -0700
Message-ID: <20121029180948.1c6a1220@nehalam.linuxnetplumber.net>
References: <20121030005731.843020405@vyatta.com>
	<20121030005835.726919547@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42014 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755746Ab2J3BKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 21:10:38 -0400
In-Reply-To: <20121030005835.726919547@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Oct 2012 17:57:37 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> Add byte queue limits for tun device transmit.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Unrelated patch, that was being tested at same time.
Ignore it.
