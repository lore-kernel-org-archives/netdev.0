From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/core: Fix BUG to BUG_ON conditionals.
Date: Sun, 08 Oct 2017 21:20:41 -0700 (PDT)
Message-ID: <20171008.212041.2197725392685274593.davem@davemloft.net>
References: <20171008191720.prewqllyazdstwkp@debian>
        <20171008200338.2noygmfbdri6lc4y@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, soheil@google.com,
        elena.reshetova@intel.com, pabeni@redhat.com, tom@quantonium.net,
        Jason@zx2c4.com, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexander.levin@one.verizon.com
To: devtimhansen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171008200338.2noygmfbdri6lc4y@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Hansen <devtimhansen@gmail.com>
Date: Sun, 8 Oct 2017 16:03:38 -0400

> Mistakenly sent the patch previously with a missing semicolon.
> Apologies.
> 
> Fix BUG() calls to use BUG_ON(conditional) macros.
> 
> This was found using make coccicheck M=net/core on linux next
> tag next-20170929
> 
> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>

You're going to have to submit this new version again, the way you
replied to the original patch caused the fixed version to not get
queued up in patchwork properly.
