From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: [2.6.9] Networking crash, slightly exotic setup, bridged
 tap/tun interfaces
Date: Wed, 15 Dec 2004 13:43:47 +1030
Message-ID: <20041215134347.58e366c9.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20041214105245.32c9b1a6.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<41BE2B20.5080602@conectiva.com.br>
	<20041214113036.3ccb3480.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<41BE320A.8090201@conectiva.com.br>
	<20041215000213.77cc0fa0.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20041215000213.77cc0fa0.random@72616e646f6d20323030342d30342d31360a.nosense.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 00:02:13 +1030
Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
wrote:


> 
> I'll leave it running overnight in this configuration to see how it
> goes.
> 

As a follow up, it has now been running for at least twelve hours,
happily trading OSPF hellos and periodic LSA flooded updates. No
problems so far, so what ever was causing the problems I was having
seems to have been fixed between 2.6.9 and 2.6.10-rc3.

I've put together a tarball containing notes on how I set it all up and
the config files I used. If anybody is interested in it, send me an
email privately, and I'll send it to you. It's only 19KB, I was tempted
to attach it to this email, but figured its probably bad nettiquet to
do so :-)

Thanks,
Mark.
