From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v1 1/2] bpf: Move check_uarg_tail_zero() upward
Date: Mon, 07 Aug 2017 20:24:16 +0200
Message-ID: <5988B050.3010203@iogearbox.net>
References: <20170807163605.14194-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>,
        Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807163605.14194-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/07/2017 06:36 PM, Mickaël Salaün wrote:
> The function check_uarg_tail_zero() may be useful for other part of the
> code in the syscall.c file. Move this function at the beginning of the
> file.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Martin KaFai Lau <kafai@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
