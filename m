From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: [2.6.9] Networking crash, slightly exotic setup, bridged
 tap/tun interfaces
Date: Tue, 14 Dec 2004 11:30:36 +1030
Message-ID: <20041214113036.3ccb3480.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20041214105245.32c9b1a6.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<41BE2B20.5080602@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41BE2B20.5080602@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Arnaldo,

Thanks for getting back to me so quickly.

On Mon, 13 Dec 2004 21:52:00 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Mark Smith wrote:
> > My kernel is only slightly modified from vanilla 2.6.9 - I've
> > increased
> 
> Can you reproduce this with 2.6.10-rc3? 2.6.9 had several networking
> bugs fixed already in 2.6.10-rc3.
> 

I'll install that, and report back a bit later. I've tended to stick to
"full figure" kernels to stay a bit more stable.

Admittedly, I don't know exactly what caused the oops, other than the
configuration I was playing with, so I don't think I can trigger
it on demand. I'll see how I go.

Thanks again,
Mark.

-- 
