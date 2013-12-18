From: Francesco Fusco <ffusco@redhat.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 18 Dec 2013 16:10:16 +0100
Message-ID: <52B1BAD8.2060606@redhat.com>
References: <20131218125643.8ff140371e1f8c306327d354@canb.auug.org.au> <20131217.212145.893665929052097867.davem@davemloft.net> <20131217.213033.1019416869378407851.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	dborkman@redhat.com, tgraf@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131217.213033.1019416869378407851.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/18/2013 03:30 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 17 Dec 2013 21:21:45 -0500 (EST)
>
>> I'll try to fix this up, thanks for the report.
>
> Here's what I committed, thanks again Stephen:
>
> ====================
> [PATCH] lib: Add missing arch generic-y entries for asm-generic/hash.h
>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Sorry for the inconvenient. Thanks for fixing it up.

Francesco
