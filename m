From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Bug-hunting
Date: Wed, 23 Feb 2005 11:53:46 -0800
Message-ID: <20050223115346.2f08866b.davem@davemloft.net>
References: <421B4AB7.9030003@rapidforum.com>
	<20050222104448.31373a99.davem@davemloft.net>
	<421B8563.9030608@rapidforum.com>
	<20050222115114.0d0e568e.davem@davemloft.net>
	<421BBE7B.1050009@rapidforum.com>
	<20050222193000.404ae6d2.davem@davemloft.net>
	<421C5AC8.70601@rapidforum.com>
	<20050223112927.349550d0.davem@davemloft.net>
	<421CDC73.9080006@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <421CDC73.9080006@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005 20:41:39 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> /proc/sys/net/ipv4/tcp_mem?
> 
> Its set to 98304   131072  196608
> I have changed this to 1024000 1025000 1026000
> 
> It didnt change anything. The send-buffer still keeps being shrinked down.

That's why I felt silly telling you again where the limit
is configured.

Please write the test program already.
