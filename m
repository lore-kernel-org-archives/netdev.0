From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch 1/1] err1-62: ax25_ds_idletimer_expiry() locking fix
Date: Mon, 5 Jul 2004 16:03:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705160355.1e730c9a.davem@redhat.com>
References: <200407020829.i628TNG20391@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200407020829.i628TNG20391@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 02 Jul 2004 01:28:24 -0700
akpm@osdl.org wrote:

> Fix deadlock identified by the Stanford locking checker.
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied.
