From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [ANNOUNCE] netplug, a daemon that handles network cables getting plugged in and out
Date: Thu, 28 Aug 2003 22:46:52 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828224652.A13004@infradead.org>
References: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Bryan O'Sullivan" <bos@keyresearch.com>
Content-Disposition: inline
In-Reply-To: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>; from bos@keyresearch.com on Thu, Aug 28, 2003 at 02:21:52PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 28, 2003 at 02:21:52PM -0700, Bryan O'Sullivan wrote:
> Netplug is a daemon that responds to network cables being plugged in or
> out by bringing a network interface up or down.  This is extremely
> useful for DHCP-managed systems that move around a lot, such as laptops
> and systems in cluster environments.

What's the difference to / advantage over ifplugd?
