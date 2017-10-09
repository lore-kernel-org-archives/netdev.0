From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] once: switch to new jump label API
Date: Mon, 09 Oct 2017 14:17:27 -0700 (PDT)
Message-ID: <20171009.141727.784767687430271381.davem@davemloft.net>
References: <20170916040751.GA14238@zzz.localdomain>
        <20171009202708.GB67463@gmail.com>
        <59DBE6C2.40104@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiggers3@gmail.com, hannes@stressinduktion.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbaron@akamai.com, peterz@infradead.org, ebiggers@google.com
To: daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59DBE6C2.40104@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 09 Oct 2017 23:14:42 +0200

> Given original code was accepted against net-next tree as major
> users of the api are networking related anyway, it should be fine
> here as well to route through this tree. Maybe resend the patch with
> a [PATCH net-next] in the subject line (as usually done) to make the
> targeted tree more clear.

Indeed, please do, sorry for not replying.
