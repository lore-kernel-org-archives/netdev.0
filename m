From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH][next][V2] bpf: test_maps: fix typo "conenct" -> "connect"
Date: Wed, 30 Aug 2017 15:46:33 +0200
Message-ID: <59A6C1B9.3050005@iogearbox.net>
References: <20170830114730.28550-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830114730.28550-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/30/2017 01:47 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> Trivial fix to typo in printf error message
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

For net-next; looks like there is also one in "failed to listeen\n".
Want to fix this one as well ? ;)

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
