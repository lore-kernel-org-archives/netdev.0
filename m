From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] net/sctp/socket.c: squish warning
Date: Sun, 03 Jan 2010 21:26:14 -0800 (PST)
Message-ID: <20100103.212614.88335472.davem@davemloft.net>
References: <200912220025.nBM0P6iQ005122@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrei@iptel.org, vladislav.yasevich@hp.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752378Ab0ADF0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:26:12 -0500
In-Reply-To: <200912220025.nBM0P6iQ005122@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 21 Dec 2009 16:25:06 -0800

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> net/sctp/socket.c: In function 'sctp_setsockopt_autoclose':
> net/sctp/socket.c:2090: warning: comparison is always false due to limited range of data type
> 
> Cc: Andrei Pelinescu-Onciul <andrei@iptel.org>
> Cc: Vlad Yasevich <vladislav.yasevich@hp.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
