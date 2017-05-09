From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 2/5] ipsec: check return value of skb_to_sgvec always
Date: Tue, 9 May 2017 16:09:49 +0200
Message-ID: <CAHmME9rdOuen8fLB8STVtBKj7BFG404N_E2MM6uoNrhhLN7auw@mail.gmail.com>
References: <20170509135009.13751-1-Jason@zx2c4.com> <20170509135009.13751-3-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509135009.13751-3-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(The next submission of this ipsec patch will have this rebased over
the latest upstream tree.
https://git.zx2c4.com/linux-dev/log/?h=jd/safe-skb-vec )
