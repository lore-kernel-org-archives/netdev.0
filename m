From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: wiznet: avoid format string exposure
Date: Thu, 06 Apr 2017 13:38:34 -0700 (PDT)
Message-ID: <20170406.133834.409433115617380761.davem@davemloft.net>
References: <20170405213935.GA4561@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akinobu.mita@gmail.com,
        edumazet@google.com, tj@kernel.org, fw@strlen.de,
        bhaktipriya96@gmail.com, yamada.masahiro@socionext.com,
        netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405213935.GA4561@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 5 Apr 2017 14:39:35 -0700

> While unlikely, this makes sure any format strings in the device name
> can't exposure information via the resulting workqueue name.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
