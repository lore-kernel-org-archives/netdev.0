From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] test_bpf: Add a couple of tests for BPF_JSGE.
Date: Thu, 25 May 2017 01:52:49 +0200
Message-ID: <59261CD1.4090001@iogearbox.net>
References: <20170524233549.18388-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524233549.18388-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/25/2017 01:35 AM, David Daney wrote:
> Some JITs can optimize comparisons with zero.  Add a couple of
> BPF_JSGE tests against immediate zero.
>
> Signed-off-by: David Daney <david.daney@cavium.com>

Thanks for the tests!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
