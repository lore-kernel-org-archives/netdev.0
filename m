From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] clean up the divert ifdef mess
Date: Tue, 20 May 2003 18:56:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.185628.116357405.davem@redhat.com>
References: <20030520173044.A21103@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030520173044.A21103@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Tue, 20 May 2003 17:30:44 +0200

   With some stubs in divert.h this looks a lot nicer.  Compile-tested with
   and without CONFIG_NET_DIVERT.
   
Applied, thanks.
