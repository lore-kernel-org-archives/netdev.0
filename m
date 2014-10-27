From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ipx: replace __inline__ by inline
Date: Mon, 27 Oct 2014 15:46:44 -0400 (EDT)
Message-ID: <20141027.154644.1712309471040445929.davem@davemloft.net>
References: <1414433352-29210-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414433352-29210-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 27 Oct 2014 19:09:12 +0100

> Signed-off-by: Fabian Frederick <fabf@skynet.be>

If it's in a foo.c file, just kill the inline completely and let the
compiler decide.

Thanks.
