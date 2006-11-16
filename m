From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.20 rebased
Date: Thu, 16 Nov 2006 15:41:11 -0500 (EST)
Message-ID: <20061116.154111.48531858.davem@davemloft.net>
References: <20061116.055840.78704296.davem@davemloft.net>
	<20061116120423.GF29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:38120 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1424471AbWKPUlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 15:41:11 -0500
To: viro@ftp.linux.org.uk
In-Reply-To: <20061116120423.GF29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Thu, 16 Nov 2006 12:04:23 +0000

> FWIW, with these patches in we have net/ nearly endian-clean.  Two
> major exceptions are ieee80211 and sctp.  I think I've got more or
> less sane way to deal with the latter, it won't be fun (and yes,
> that's the queue I'm currently getting into shape).  A bunch of
> genuine bugs in there, too, especially when it comes to sctp+ipv6...

Looking forward to seeing that stuff Al.
