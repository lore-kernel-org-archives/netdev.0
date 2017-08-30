From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH][net-next][V3] bpf: test_maps: fix typos, "conenct" and
 "listeen"
Date: Wed, 30 Aug 2017 10:31:51 -0700
Message-ID: <59A6F687.5020204@gmail.com>
References: <20170830171525.5688-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830171525.5688-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2017 10:15 AM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to typos in printf error messages:
> "conenct" -> "connect"
> "listeen" -> "listen"
> 
> thanks to Daniel Borkmann for spotting one of these mistakes
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---

Thanks. Even though its a spelling typo best to add fixes tag
I think.

Fixes: 6f6d33f3b3d0 ("bpf: selftests add sockmap tests")
Acked-by: John Fastabend <john.fastabend@gmail.com>
