From: Joe Perches <joe@perches.com>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 11:28:05 -0700
Message-ID: <1276626485.1586.96.camel@Joe-Laptop.home>
References: <1276580526.30434.330.camel@edumazet-laptop>
	 <20100614.225910.104075511.davem@davemloft.net>
	 <1276618932.1586.64.camel@Joe-Laptop.home>
	 <20100615.102305.28825768.davem@davemloft.net>
	 <1276625060.2541.166.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1144 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754268Ab0FOS2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 14:28:08 -0400
In-Reply-To: <1276625060.2541.166.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-15 at 20:04 +0200, Eric Dumazet wrote:
> I am very old school, and use a text editor I co-wrote in
> 1986 ;)

I gave up writing my own text editors in the 70's,
but finger habits are hard to break.

> Hmm ?

Move up to the (late?) 80's... ;)

> Oh well...

Perhaps a new git blame based command would be useful
	git blame -L <range> ---history 
kind of an expanded, human friendly --incremental.
Show how the file range appeared with each previous revision.

