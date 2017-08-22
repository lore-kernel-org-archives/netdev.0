From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] arm: eBPF JIT compiler
Date: Tue, 22 Aug 2017 09:28:15 -0700 (PDT)
Message-ID: <20170822.092815.433603069354349639.davem@davemloft.net>
References: <1503383553-5650-1-git-send-email-illusionist.neo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@armlinux.org.uk, netdev@vger.kernel.org, ast@fb.com,
        daniel@iogearbox.net, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, keescook@chromium.org, andrew@lunn.ch
To: illusionist.neo@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503383553-5650-1-git-send-email-illusionist.neo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shubham Bansal <illusionist.neo@gmail.com>
Date: Tue, 22 Aug 2017 12:02:33 +0530

> The JIT compiler emits ARM 32 bit instructions. Currently, It
> supports eBPF only. Classic BPF is supported because of the
> conversion by BPF core.
 ...

Applied to net-next, thanks.
