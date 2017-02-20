From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/3] bpf: make jited programs visible in traces
Date: Mon, 20 Feb 2017 20:07:37 +0100
Message-ID: <58AB3E79.7040307@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>  <36bb0882151c63dcf7c624f52bf92db8adbfb80a.1487279499.git.daniel@iogearbox.net> <1487617532.1311.113.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487617532.1311.113.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/20/2017 08:05 PM, Eric Dumazet wrote:
[...]
> Latest net-next tree dies on my hosts, and my bisection came to this
> commit.

Thanks for the report, I'll take a look!
