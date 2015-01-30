From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 9/9] netfilter: nf_tables: add support for dynamic set updates
Date: Fri, 30 Jan 2015 10:08:46 +0000
Message-ID: <C08F666A-DAAF-4C61-A9F3-DBB3D936B4B4@trash.net>
References: <1422603994-5836-1-git-send-email-kaber@trash.net> <1422603994-5836-10-git-send-email-kaber@trash.net> <20150130092845.GA18725@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: tgraf@suug.ch, davem@davemloft.net, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150130092845.GA18725@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 30. Januar 2015 09:28:45 GMT+00:00, schrieb Herbert Xu <herbert@gondor.apana.org.au>:
>On Fri, Jan 30, 2015 at 07:46:34AM +0000, Patrick McHardy wrote:
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>
>I presume this can't create any jumps/gotos, right?

So far not, just data mappings. Not sure yet if there is a valid use case for jumps.
>
>Thanks,


