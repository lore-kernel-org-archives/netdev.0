From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix ROSE security hole
Date: Thu, 10 Mar 2005 19:47:02 -0800
Message-ID: <20050310194702.1b812b51.davem@davemloft.net>
References: <20050302090658.GA6873@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20050302090658.GA6873@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2005 09:06:58 +0000
Ralf Baechle <ralf@linux-mips.org> wrote:

> ROSE wasn't verifying the ndigis argument of a new route resulting in a
> minor security hole.

Also applied, thanks Ralf.
