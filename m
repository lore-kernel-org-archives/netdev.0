From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] bpf: Move check_uarg_tail_zero() upward
Date: Tue, 08 Aug 2017 18:11:28 -0700 (PDT)
Message-ID: <20170808.181128.361728266111595998.davem@davemloft.net>
References: <20170807184520.8130-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        keescook@chromium.org, kafai@fb.com, netdev@vger.kernel.org,
        ast@kernel.org
To: mic@digikod.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807184520.8130-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>
Date: Mon,  7 Aug 2017 20:45:19 +0200

> The function check_uarg_tail_zero() may be useful for other part of the
> code in the syscall.c file. Move this function at the beginning of the
> file.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
