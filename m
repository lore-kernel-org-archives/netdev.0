From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Bug-hunting
Date: Wed, 23 Feb 2005 20:46:29 +0100
Message-ID: <421CDD95.2020108@rapidforum.com>
References: <421B4AB7.9030003@rapidforum.com>	<20050222104448.31373a99.davem@davemloft.net>	<421B8563.9030608@rapidforum.com>	<20050222115114.0d0e568e.davem@davemloft.net>	<421BBE7B.1050009@rapidforum.com>	<20050222193000.404ae6d2.davem@davemloft.net>	<421C5AC8.70601@rapidforum.com> <20050223112927.349550d0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050223112927.349550d0.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can I see somewhere how much memory tcp needs right now so to see if that changes effect something? 
Maybe the error is somewhere else so I need to check if memory-usage raises if I change the values.

David S. Miller wrote:
> On Wed, 23 Feb 2005 11:28:24 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> 
>>I would have to write a test-program first. This needs time. Before I spend hours into coding this, 
>>first just tell me how I can raise the global-limit from around 600-700 MB to 1500 MB.
> 
> 
> The limit is in the tcp_mem sysctl, I believe we told you this
> before.
> 
> 
