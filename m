From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] atm: idt77105: Drop needless setup_timer()
Date: Wed, 11 Oct 2017 14:15:37 -0700 (PDT)
Message-ID: <20171011.141537.734027810039462075.davem@davemloft.net>
References: <1507663550-13343-1-git-send-email-keescook@chromium.org>
        <1507663550-13343-2-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, 3chas3@gmail.com,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507663550-13343-2-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 10 Oct 2017 12:25:48 -0700

> Calling setup_timer() is redundant when DEFINE_TIMER() has been used.
> 
> Cc: Chas Williams <3chas3@gmail.com>
> Cc: linux-atm-general@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied to net-next, thanks.
