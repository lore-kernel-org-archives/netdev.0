From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 09:03:34 -0800
Message-ID: <50FC2366.1000509@zytor.com>
References: <2012247681.93123.1358694444237.JavaMail.root@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <bitbucket@online.de>,
	Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: Tom St Denis <tstdenis@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2012247681.93123.1358694444237.JavaMail.root@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/20/2013 07:07 AM, Tom St Denis wrote:
>
> In all likelihood I will submit a revised CMAC patch but it'll take
> time before I can get business hours to work on it.  So instead of
> having a maintainer just touch it up we're all going to lose out
> because of pride?
>

It's not about pride.  It is about the fact that maintainers don't 
scale.  A single troublesome contributor can easily take up as much 
maintainer time as over a dozen contributors who know how to work well 
with their upstream.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.
