From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ircomm - set owner get rid of MOD_INC/MOD_DEC
Date: Tue, 19 Aug 2003 21:10:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819211029.2506fc55.davem@redhat.com>
References: <20030818111746.34b9e52b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030818111746.34b9e52b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 11:17:46 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Ircomm in 2.6.0-test3 can just set the owner field in the tty structure
> like other drivers, and not mess with MOD_INC/MOD_DEC.

Applied, thanks Stephen.
