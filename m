From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 2/4] samples/bpf: Enable cross compiler support
Date: Wed, 20 Sep 2017 23:24:45 +0200
Message-ID: <59C2DC9D.50208@iogearbox.net>
References: <20170920161159.25747-1-joelaf@google.com> <20170920161159.25747-2-joelaf@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, davem@davemloft.net, ast@kernel.org,
        kernel-team@android.com
To: Joel Fernandes <joelaf@google.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920161159.25747-2-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/20/2017 06:11 PM, Joel Fernandes wrote:
> When cross compiling, bpf samples use HOSTCC for compiling the non-BPF part of
> the sample, however what we really want is to use the cross compiler to build
> for the cross target since that is what will load and run the BPF sample.
> Detect this and compile samples correctly.
>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Joel Fernandes <joelaf@google.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
