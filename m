From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/4] Faster SO_REUSEPORT
Date: Mon, 04 Jan 2016 22:50:26 -0500 (EST)
Message-ID: <20160104.225026.1226480782026092997.davem@davemloft.net>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbcAEDu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:50:29 -0500
In-Reply-To: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Mon,  4 Jan 2016 17:41:44 -0500

> This series contains two optimizations for the SO_REUSEPORT feature:
> Faster lookup when selecting a socket for an incoming packet and
> the ability to select the socket from the group using a BPF program.
> 
> This series only includes the UDP path.  I plan to submit a follow-up
> including the TCP path if the implementation in this series is
> acceptable.

This series looks great!

Applied, thanks Craig.
