From: "David S. Miller" <davem@davemloft.net>
Subject: Re: is UDP_CORK "real"
Date: Thu, 21 Apr 2005 16:25:05 -0700
Message-ID: <20050421162505.3db8ed7c.davem@davemloft.net>
References: <426833F0.9010803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <426833F0.9010803@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Apr 2005 16:14:56 -0700
Rick Jones <rick.jones2@hp.com> wrote:

> Is UDP_CORK going to be an ongoing feature?

Yes, it's there and it's real.

If netperf is passing a TCP socket option number in for
a setsockopt() on a UDP socket, how in the world is that
the kernel's problem?
