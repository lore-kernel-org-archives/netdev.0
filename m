From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Bug-hunting
Date: Wed, 23 Feb 2005 11:29:27 -0800
Message-ID: <20050223112927.349550d0.davem@davemloft.net>
References: <421B4AB7.9030003@rapidforum.com>
	<20050222104448.31373a99.davem@davemloft.net>
	<421B8563.9030608@rapidforum.com>
	<20050222115114.0d0e568e.davem@davemloft.net>
	<421BBE7B.1050009@rapidforum.com>
	<20050222193000.404ae6d2.davem@davemloft.net>
	<421C5AC8.70601@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <421C5AC8.70601@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005 11:28:24 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> I would have to write a test-program first. This needs time. Before I spend hours into coding this, 
> first just tell me how I can raise the global-limit from around 600-700 MB to 1500 MB.

The limit is in the tcp_mem sysctl, I believe we told you this
before.
