From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 19 Oct 2017 15:08:42 +0200
Message-ID: <59E8A3DA.5070905@iogearbox.net>
References: <20171019130530.ipxwriotybk3ofbd@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019130530.ipxwriotybk3ofbd@sirena.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2017 03:05 PM, Mark Brown wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    tools/testing/selftests/bpf/test_verifier.c
>
> between commit:
>
>    28e33f9d78eef ("bpf: disallow arithmetic operations on context pointer")
>
> from the net tree and commit:
>
>    22c8852624fc9 ("bpf: improve selftests and add tests for meta pointer")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This

LGTM, thanks.
