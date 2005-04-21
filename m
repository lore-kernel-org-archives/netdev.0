From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET] Add missing newline for skb_*_panic
Date: Fri, 22 Apr 2005 01:25:22 +0200
Message-ID: <42683662.6060003@trash.net>
References: <20050421050815.GA23133@gondor.apana.org.au> <42682527.3000709@trash.net> <42682718.3060601@trash.net> <20050421231437.GA10119@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050421231437.GA10119@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Thanks Patrick, this looks great.

BTW, Do you know if that ppp problem (Fw: [Bugme-new] [Bug 4381] New:
When i try to start a pppoe conn., crash at net/core/skbuff.c:91) was
already fixed? Otherwise I'd suggest that the reporter should capture
a crash again with this patch applied.

Regards
Patrick
