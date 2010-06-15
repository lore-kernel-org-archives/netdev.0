From: Joe Perches <joe@perches.com>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 10:51:52 -0700
Message-ID: <1276624312.1586.83.camel@Joe-Laptop.home>
References: <1276618932.1586.64.camel@Joe-Laptop.home>
	 <20100615.102305.28825768.davem@davemloft.net>
	 <1276623750.1586.81.camel@Joe-Laptop.home>
	 <20100615.104625.179919135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1141 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab0FORvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 13:51:54 -0400
In-Reply-To: <20100615.104625.179919135.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-15 at 10:46 -0700, David Miller wrote:
> I want a command line I can
> type in which gives me the answer.  "git blame" on the surface
> can do this, and most of the time it serves my needs, but as soon
> as rabid cleanups enter into the picture, the tool becomes useless.

akin to git blame --L <range> --history?


