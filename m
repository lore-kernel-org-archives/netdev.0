From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [PATCH] Make netif_rx_ni preempt-safe
Date: Wed, 20 Oct 2004 12:47:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098290858.1429.70.camel@krustophenia.net>
References: <1098230132.23628.28.camel@krustophenia.net>
	 <20041020000009.GA17246@gondor.apana.org.au>
	 <1098231737.23628.42.camel@krustophenia.net>
	 <200410201811.44419.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Andrew Morton <akpm@osdl.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@gondor.apana.org.au, maxk@qualcomm.com,
        irda-users@lists.sourceforge.net,
        Linux Network Development <netdev@oss.sgi.com>,
        Alain Schroeder <alain@parkautomat.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200410201811.44419.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-10-20 at 11:11, Denis Vlasenko wrote:
> 0x57 == 87 bytes is too big for inline.

Ugh.  So the only fix is not to inline it?

Lee
