From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH 5/5] r8169: ethtool hardware statistics support
Date: Sat, 12 Mar 2005 12:32:05 +0000
Message-ID: <4232E145.5030005@phekda.gotadsl.co.uk>
References: <20050309113626.6708c93e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309113626.6708c93e@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Stephen Hemminger wrote:
> Add ethtool support for dumping the chip statistics. There aren't lots
> of statistics available, but this is what is available according to the RealTek
> documentation.
[snip]

Works fine for me on my Athlon64 laptop with a 8169 with built-in PHY.

Did some rsync'ing and some broadcast pings. Statistics looked sane. 
Also tried stopping networking ("/etc/init.d/network stop") and checked 
that all the stats had been reset to zero.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
