From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 6/22] xfrm: add a parameter to xfrm_prune_bundles()
Date: Fri, 21 Jan 2005 15:21:27 -0800
Message-ID: <20050121152127.0a89a768.davem@davemloft.net>
References: <20041230035000.14@ori.thedillows.org>
	<20041230035000.15@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <20041230035000.15@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:48:35 -0500
David Dillow <dave@thedillows.org> wrote:

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2004/12/30 00:35:34-05:00 dave@thedillows.org 
> #   Add a parameter to the decision function(s) used by
> #   xfrm_prune_bundles(). This will allow us to have more
> #   fine grained selection of bundles pruned (like, say,
> #   per device.)
> #   
> #   Signed-off-by: David Dillow <dave@thedillows.org>

This one looks OK.
