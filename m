From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] Fix missing dependency of PCH_GBE driver
Date: Thu, 28 Oct 2010 13:31:07 -0400
Message-ID: <1288287067.18238.272.camel@gandalf.stny.rr.com>
References: <1288268189.18238.173.camel@gandalf.stny.rr.com>
	 <20101028.101618.226776102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	error27@gmail.com, masa-korg@dsn.okisemi.com,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:33111 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420Ab0J1RbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:31:10 -0400
In-Reply-To: <20101028.101618.226776102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-28 at 10:16 -0700, David Miller wrote:

> The canonical way to handle this is to use 'select'.  Thus,
> I've committed the following to fix this.

Yeah, I was thinking that too after I posted it.

-- Steve


