From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use memdup_user
Date: Tue, 16 May 2017 11:30:36 +0200
Message-ID: <20170516093036.GC2631@secunet.com>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
 <7d89949ab688323cf05273b7dfaca94348118594.1493780592.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7d89949ab688323cf05273b7dfaca94348118594.1493780592.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 06, 2017 at 11:42:21PM +0800, Geliang Tang wrote:
> Use memdup_user() helper instead of open-coding to simplify the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied to ipsec-next, thanks!
