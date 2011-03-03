From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_RXRPC: Handle receiving ACKALL packets
Date: Wed, 02 Mar 2011 22:19:44 -0800 (PST)
Message-ID: <20110302.221944.246546883.davem@davemloft.net>
References: <20110228132743.30463.33897.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110228132743.30463.33897.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 28 Feb 2011 13:27:43 +0000

> The OpenAFS server is now sending ACKALL packets, so we need to handle them.
> Otherwise we report a protocol error and abort.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
