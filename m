From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RxRPC: Fix missing __user annotation
Date: Tue, 09 Sep 2014 20:40:10 -0700 (PDT)
Message-ID: <20140909.204010.1603269511237977404.davem@davemloft.net>
References: <20140909141944.18112.74852.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140909141944.18112.74852.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Tue, 09 Sep 2014 15:19:44 +0100

> Fix a missing __user annotation in a cast of a user space pointer (found by
> checker).
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied.
