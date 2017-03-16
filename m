From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: fs_enet: Remove useless includes
Date: Thu, 16 Mar 2017 11:15:27 -0700 (PDT)
Message-ID: <20170316.111527.1404979274995491797.davem@davemloft.net>
References: <20170316091804.DCA4168481@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316091804.DCA4168481@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Thu, 16 Mar 2017 10:18:04 +0100 (CET)

> CONFIG_8xx is being deprecated. Since the includes dependent on
> CONFIG_8xx are useless, just drop them.
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Applied.
