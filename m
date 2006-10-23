From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: Re: [PATCH 2/6] [CRYPTO] added the code of Camellia cipher
 algorithm.
Date: Mon, 23 Oct 2006 11:33:10 +0900 (JST)
Message-ID: <20061023.113310.796983746.takamiya@po.ntts.co.jp>
References: <20061018.161510.796986352.takamiya@po.ntts.co.jp>
	<20061018.161647.1044955937.takamiya@po.ntts.co.jp>
	<20061022050954.GA24183@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20061022050954.GA24183@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Sun, 22 Oct 2006 15:09:54 +1000
>> [Subject: Re: [PATCH 2/6] [CRYPTO] added the code of Camellia cipher algorithm.]
>> Herbert Xu <herbert@gondor.apana.org.au> wrote...

> On Wed, Oct 18, 2006 at 07:16:47AM +0000, Noriaki TAKAMIYA wrote:
> >
> > +static int
> > +camellia_set_key(struct crypto_tfm *tfm, const u8 *in_key,
> > +		 unsigned int key_len, u32 *flags)
> 
> Ugh, this doesn't compile with the current tree since the flags
> field no longer exists for set_key.  I've fixed it up in my tree.

  The tree I referred might be little bit old...

  Thank you for your fix.

  Regards,

--
Noriaki TAKAMIYA
