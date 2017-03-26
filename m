From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] padata: avoid race in reordering
Date: Sat, 25 Mar 2017 20:01:51 -0700 (PDT)
Message-ID: <20170325.200151.245940842455044501.davem@davemloft.net>
References: <CAHmME9oLWiprOyZXo7zvGm7xq+1Kchw9ybLS_TM-9xDyHF0mxQ@mail.gmail.com>
        <20170323112443.30843-1-Jason@zx2c4.com>
        <20170324094157.GE5279@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jason@zx2c4.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au
To: steffen.klassert@secunet.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170324094157.GE5279@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 24 Mar 2017 10:41:59 +0100

> On Thu, Mar 23, 2017 at 12:24:43PM +0100, Jason A. Donenfeld wrote:
>> Under extremely heavy uses of padata, crashes occur, and with list
>> debugging turned on, this happens instead:
 ...
>> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> 
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>

Herbert, this should probably go via your crypto tree.
