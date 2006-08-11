From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NET 00/06]: Increase number of possible routing tables
Date: Fri, 11 Aug 2006 11:48:49 +0200
Message-ID: <20060811094849.GL14627@postel.suug.ch>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain> <44DC2617.7020200@tls.msk.ru> <20060810.234414.89236927.davem@davemloft.net> <44DC2A22.2080905@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44496 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751068AbWHKJsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 05:48:31 -0400
To: Michael Tokarev <mjt@tls.msk.ru>
Content-Disposition: inline
In-Reply-To: <44DC2A22.2080905@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Michael Tokarev <mjt@tls.msk.ru> 2006-08-11 10:56
> And while we're at it...  How about using table *names* instead of
> numbers in kernel too, a-la iptables?  Once possible number of tables
> is large, and we're using hashes for tables now anyway, keeping a
> name inside the table structure wont hurt ;)

This is and should be implemented in userspace.
