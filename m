From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCHv3 perf/core 1/6] tools lib bpf: Add BPF program pinning
 APIs.
Date: Mon, 30 Jan 2017 21:58:05 -0300
Message-ID: <20170131005805.GI4546@kernel.org>
References: <20170126212001.14103-1-joe@ovn.org>
 <20170126212001.14103-2-joe@ovn.org>
 <20170130202506.GF4546@kernel.org>
 <20170130202813.GG4546@kernel.org>
 <CAPWQB7FDThp03e6DTHio8Myv5e8J6RcDXK-jG8W6B7Sh2Gvisw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPWQB7FDThp03e6DTHio8Myv5e8J6RcDXK-jG8W6B7Sh2Gvisw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 30, 2017 at 01:16:18PM -0800, Joe Stringer escreveu:
> On 30 January 2017 at 12:28, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> > ---
> > Thus, a return value of size or more means that the output was
> > truncated.
> > ---
 
> Good spotting, I looked over the committed versions and tested them,
> they seem good to me. Thanks!

Thanks for checking, will push Ingo's way after a battery of extra
tests, tomorrow,

- Arnaldo
