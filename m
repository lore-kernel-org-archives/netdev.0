From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] arm: eBPF JIT compiler
Date: Mon, 12 Jun 2017 18:47:15 -0400 (EDT)
Message-ID: <20170612.184715.1209071551735119885.davem@davemloft.net>
References: <593E6B0F.8070901@iogearbox.net>
        <CAHgaXd+DW2bggto=2S9hOdMrtPTvhD2QN4rPf2V8iHewQpg-YA@mail.gmail.com>
        <20170612224545.GA25584@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: illusionist.neo@gmail.com, daniel@iogearbox.net,
        keescook@chromium.org, netdev@vger.kernel.org, ast@kernel.org,
        linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, andrew@lunn.ch
To: alexander@alemayhu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170612224545.GA25584@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Alemayhu <alexander@alemayhu.com>
Date: Tue, 13 Jun 2017 00:45:45 +0200

> On Mon, Jun 12, 2017 at 09:10:07PM +0530, Shubham Bansal wrote:
>> 
>> Nope. It looks like a latest addition to testing. Can you please tell
>> me how to test with it?
>>
> cd tools/testing/selftests/bpf/
> make
> sudo ./test_progs

Also, you might need to do a "make headers_install" at the top level
before doing this.
