From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2 2/2] net: ethernet: stmmac: remove private tx queue
 lock
Date: Thu, 15 Dec 2016 20:42:02 +0100
Message-ID: <e59d43c3-6c90-9aed-7a2a-001ee0edd626@gmx.de>
References: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481241343-18062-3-git-send-email-LinoSanfilippo@gmx.de>
 <CAD5ja63O5jFtt=RyXTBxRxKSaJVfyL+kFeJwwen-pt0ifQARYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ks.giri@samsung.com, linux-kernel@vger.kernel.org,
        davem@davemloft.net, bh74.an@samsung.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, pavel@ucw.cz, romieu@fr.zoreil.com,
        netdev@vger.kernel.org, vipul.pandya@samsung.com
To: Niklas Cassel <nks.gnu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD5ja63O5jFtt=RyXTBxRxKSaJVfyL+kFeJwwen-pt0ifQARYQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 15.12.2016 19:52, Niklas Cassel wrote:
> Since v1 of this patch has already been merged to net-next, I think that
> you should create a new patch on top of that, rather than submitting a v2.
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/drivers/net/ethernet/stmicro/stmmac?id=739c8e149ae40a1eb044edb92a133b93b59369d8
> 

It is v2 that has been merged, not v1. 
Both versions only differed in the commit message.

Regards,
Lino
