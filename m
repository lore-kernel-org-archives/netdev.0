From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 1/4] tr.c warning fix
Date: Thu, 24 Jun 2004 12:42:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624124234.3f2dab98.davem@redhat.com>
References: <200406240631.i5O6VSZ31238@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200406240631.i5O6VSZ31238@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jun 2004 23:30:31 -0700
akpm@osdl.org wrote:

> A few things popped up when using current gcc cvs.
> 
> net/802/tr.c: In function `tr_header':
> net/802/tr.c:113: warning: 'trh' is used uninitialized in this function
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied.
