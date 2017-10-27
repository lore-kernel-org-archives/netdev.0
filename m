From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: wan/dscc4: Remove unused timer
Date: Fri, 27 Oct 2017 12:10:20 +0900 (KST)
Message-ID: <20171027.121020.1538496259702684195.davem@davemloft.net>
References: <20171025105342.GA146617@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105342.GA146617@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:53:42 -0700

> This removes an entirely unused timer, which avoids needing to convert it
> to timer_setup().
> 
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
