From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] irda - need to set socket owner
Date: Sat, 30 Aug 2003 19:09:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030830190917.78b7a8a7.davem@redhat.com>
References: <20030829114406.52a429bd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030829114406.52a429bd.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Aug 2003 11:44:06 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> All protocols need to set the socket owner field to prevent
> module unloading when there are still orphaned sockets.

Applied, thanks.
