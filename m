From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 12:20:58 +0100
Message-ID: <4218729A.4080201@trash.net>
References: <4217266F.6090700@trash.net> <20050219184351.GB10773@gondor.apana.org.au> <42182082.9060301@trash.net> <20050220.155527.54695259.yoshfuji@linux-ipv6.org> <20050220073719.GA13008@gondor.apana.org.au> <42184BC2.1030907@trash.net> <20050220111219.GA25499@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050220111219.GA25499@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> It is looking more and more like a nasty hack though so maybe
> it's not worth it since the policy checks are still bloated enough
> even after we do this.

Agreed. Let's just take the first patch.

Regards
Patrick
