From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix uninitialized proto_list_lock
Date: Mon, 4 Apr 2005 10:42:54 -0700
Message-ID: <20050404104254.0d30ba8d.davem@redhat.com>
References: <20050404173010.GA19451@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20050404173010.GA19451@kvack.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Apr 2005 13:30:10 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

> Please apply the following patch which fixes a BUG() on boot when the 
> kernel is compiled with spinlock debugging in bk head.  Cheers,

This is already in Linus's tree.
Thanks.
