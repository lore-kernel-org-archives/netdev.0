From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH] pcnet_cs: add odd location support for write_asic
 function
Date: Sun, 12 Jul 2009 07:15:54 +0900
Message-ID: <20090712071554.f4632deb.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090711090213.94a771d3.ken_kawasaki@spring.nifty.jp>
	<20090710.202609.57274545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:29913 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbZGKWQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 18:16:24 -0400
In-Reply-To: <20090710.202609.57274545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jul 2009 20:26:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> > Currently, no one passes odd location to the write_asic function.
> > But this patch add odd location support for future usage of this
> > feature.
> > 
> > 
> > Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
> 
> "Who" in the future will use this feature and why do they
> need it?
> 
> Ideally, you should submit this patch at the same time as
> the other patch which adds a need for it.

OK.
Thanks.


