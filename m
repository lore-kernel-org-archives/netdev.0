From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 7/22] xfrm: Allow device drivers to force
 recalculation of offloads
Date: Tue, 25 Jan 2005 22:11:06 -0800
Message-ID: <20050125221106.1d87e070.davem@davemloft.net>
References: <20041230035000.15@ori.thedillows.org>
	<20041230035000.16@ori.thedillows.org>
	<20050121152358.5c60d0db.davem@davemloft.net>
	<1106373216.3691.43.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1106373216.3691.43.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Jan 2005 00:53:36 -0500
David Dillow <dave@thedillows.org> wrote:

> In patch 3 of the series, xfrm_offload_add() grabs a reference to the
> device, and xfrm_offload_release() releases it when the offload's own
> reference count hits zero.

Perfect.
