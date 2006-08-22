From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5][SCTP]: Use the flags value that is passed as an
 arg to sctp_accept.
Date: Tue, 22 Aug 2006 00:24:20 -0700 (PDT)
Message-ID: <20060822.002420.80876314.davem@davemloft.net>
References: <Pine.LNX.4.58.0608181501560.7947@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2480
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750970AbWHVHYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:24:16 -0400
To: sri@us.ibm.com
In-Reply-To: <Pine.LNX.4.58.0608181501560.7947@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 18 Aug 2006 15:02:57 -0700 (PDT)

> [SCTP]: Use the flags value that is passed as an arg to sctp_accept.
> 
> No need to do multiple dereferences - sk->sk_socket->file->f_flags
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks a lot.
