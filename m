From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Ethtool offload patch
Date: Tue, 4 Jan 2005 09:44:23 -0800
Message-ID: <20050104094423.2d404759.davem@davemloft.net>
References: <1104396895.5845.1.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1104396895.5845.1.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Dec 2004 03:54:55 -0500
David Dillow <dave@thedillows.org> wrote:

> The attached patch allows the ethtool userspace tool to query and
> control IPSEC crypto offload.

Aren't you going to need something much more sophisticated
than a boolean on/off value?  How can I tell the driver
"offload 3DES ESP, but not AH at all" or something like
that?
