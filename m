From: Joe Perches <joe@perches.com>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 09:22:12 -0700
Message-ID: <1276618932.1586.64.camel@Joe-Laptop.home>
References: <1276561234.4897.38.camel@Joe-Laptop.home>
	 <1276580526.30434.330.camel@edumazet-laptop>
	 <20100614.225910.104075511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1135 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925Ab0FOQWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 12:22:15 -0400
In-Reply-To: <20100614.225910.104075511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-14 at 22:59 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 15 Jun 2010 07:42:06 +0200
> > It's hard to point out the origin of a particular
> > bug/code, and we have to spend precious time playing with complex git
> > commands to go over cleanup patches.

Eric, can you explain your process please.

[]

> But that to me just means that until git has a friendlier way to
> walk backwards through blame information for a line to skip past
> the cleanup crapola, we shouldn't make a lot of these kinds of
> changes.

What do you think is missing from the gitk file viewer?

