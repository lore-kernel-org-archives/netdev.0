From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Badness in cache_free_debugcheck at linux/mm/slab.c:1909
Date: Thu, 28 Apr 2005 12:09:58 -0700
Message-ID: <20050428120958.2f0ad8fd.davem@davemloft.net>
References: <20050427150518.A15989@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk@arm.linux.org.uk>
In-Reply-To: <20050427150518.A15989@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Apr 2005 15:05:18 +0100
Russell King <rmk@arm.linux.org.uk> wrote:

> This pretty much sums up the problem:

Yes, Arnaldo is looking into this bug.
