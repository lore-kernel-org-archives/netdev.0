From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] bpf: Remove redundant ifdef
Date: Wed, 15 Feb 2017 12:15:12 -0500 (EST)
Message-ID: <20170215.121512.968038975885762468.davem@davemloft.net>
References: <20170211193708.18191-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        wangnan0@huawei.com, netdev@vger.kernel.org
To: mic@digikod.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170211193708.18191-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>
Date: Sat, 11 Feb 2017 20:37:08 +0100

> Remove a useless ifdef __NR_bpf as requested by Wang Nan.
> 
> Inline one-line static functions as it was in the bpf_sys.h file.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Wang Nan <wangnan0@huawei.com>
> Link: https://lkml.kernel.org/r/828ab1ff-4dcf-53ff-c97b-074adb895006@huawei.com

Applied.
