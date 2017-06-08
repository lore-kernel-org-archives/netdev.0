From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: next-20170608 build: 1 failures 4 warnings (next-20170608)
Date: Thu, 8 Jun 2017 20:27:04 +1000
Message-ID: <20170608202704.1469d0bf@canb.auug.org.au>
References: <E1dIuCM-0000cQ-QM@optimist>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Build bot for Mark Brown <broonie@kernel.org>,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <E1dIuCM-0000cQ-QM@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Thu, 08 Jun 2017 10:57:50 +0100 Build bot for Mark Brown <broonie@kernel.org> wrote:
>
> Tree/Branch: next-20170608
> Git describe: next-20170608
> Commit: e4689b9aad Add linux-next specific files for 20170608
> 
> Build Time: 0 min 12 sec
> 
> Passed:    6 / 7   ( 85.71 %)
> Failed:    1 / 7   ( 14.29 %)
> 
> Errors: 1
> Warnings: 4
> Section Mismatches: 0
> 
> Failed defconfigs:
> 	arm-allmodconfig
> 
> Errors:
> 
> 	arm-allmodconfig
> ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_device' has no member named 'destructor'

Looks like Mark has found another one.

-- 
Cheers,
Stephen Rothwell
