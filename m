From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 2 Apr 2009 22:15:39 +0800
Message-ID: <20090402141539.GA435@gondor.apana.org.au>
References: <20090323.013749.122944803.davem@davemloft.net> <20090402141342.GA377@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, jarkao2@gmail.com, vernux@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760029AbZDBOQN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090402141342.GA377@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 02, 2009 at 10:13:42PM +0800, Herbert Xu wrote:
>
> Come on guys, if this lock is a problem. go out and buy a proper
> NIC that supports multiequeue TX!

Nevermind, I was reading old emails again :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
