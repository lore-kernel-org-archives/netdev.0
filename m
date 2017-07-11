From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: stmmac: Fixes and cleanups in
 'alloc_dma_[rt]x_desc_resources()'
Date: Tue, 11 Jul 2017 13:34:11 -0700 (PDT)
Message-ID: <20170711.133411.864910706448052867.davem@davemloft.net>
References: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1499499451.git.christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sat,  8 Jul 2017 09:46:12 +0200

> These patchs are all related to 'alloc_dma_[rt]x_desc_resources()' functions.
> 
> The 2 first fix an error path where some resources are leaking. I've
> separated them into 2 patches because the issues have been introduced by
> 2 deferent commits.
> 
> The 3rd patch is just a clean-up.

Series applied, thanks.
