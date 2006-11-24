From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Networking: re-fix of doc-comment in sock.h
Date: Thu, 23 Nov 2006 20:56:24 -0500 (EST)
Message-ID: <20061123.205624.74734820.davem@davemloft.net>
References: <20061118082727.GA1250@pib>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:27803 "EHLO localhost")
	by vger.kernel.org with ESMTP id S1757510AbWKXB4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 20:56:24 -0500
To: misterpib@gmail.com
In-Reply-To: <20061118082727.GA1250@pib>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bonser <misterpib@gmail.com>
Date: Sat, 18 Nov 2006 00:27:27 -0800

> From: Paul Bonser <misterpib@gmail.com>
> 
> Restoring old, correct comment for sk_filter_release, moving it to where it should actually be, and changing new comment into proper comment for sk_filter_rcu_free, where it actually makes sense.
> 
> The original fix submitted for this on Oct 23 mistakenly documented the wrong function.
> 
> Signed-off-by: Paul Bonser <misterpib@gmail.com>

Applied, thanks.
