From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] set owner field on /proc/net/irda sub entries
Date: Tue, 19 Aug 2003 21:11:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819211133.0504abf4.davem@redhat.com>
References: <20030818111942.6060b450.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, netdev@oss.sgi.com,
   irda-users@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030818111942.6060b450.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 11:19:42 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> common net/irda code in 2.6.0-test3 creates directory and sub entries,
> but forgets to set owner field on sub entries.

Applied, thanks Stephen.
