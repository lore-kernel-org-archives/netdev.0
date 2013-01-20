From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 14:34:20 +0100
Message-ID: <50FBF25C.4030604@ahsoftware.de>
References: <313650836.93071.1358686587647.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Borislav Petkov <bp@alien8.de>, Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>,
	Mike Galbraith <bitbucket@online.de>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <313650836.93071.1358686587647.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 20.01.2013 13:56, schrieb Tom St Denis:

> You should really try running checkpatch.pl over code that's already in the kernel before you call out new contributors on it.
>
> How is this supposed to not be adversarial when I can't even use the Kernel source itself as a reference?

In case of the kernel the chicken and egg problem can be answered 
without any questions, most source existed before checkpatch.pl (evolved 
to the current state).

Regards,

Alexander
