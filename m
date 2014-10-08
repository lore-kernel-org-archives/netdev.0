From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: description of dma_cookie cause make xmldocs warning
Date: Wed, 08 Oct 2014 19:59:34 +0400
Message-ID: <54355F66.6060204@cogentembedded.com>
References: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams@intel.com
To: Masanari Iida <standby24x7@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/08/2014 06:53 PM, Masanari Iida wrote:

> In commit 7bced397510ab569d31de4c70b39e13355046387,

    Please also specify that commit's summary line in parens.

> dma_cookie was removed from struct skbuff.
> But the description of dma_cookie still exist.
> So the "make xmldocs" output following warning.

> Warning(.//include/linux/skbuff.h:609): Excess struct/union
> /enum/typedef member 'dma_cookie' description in 'sk_buff'

> Remove description of dma_cookie fix the symptom.

> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

WBR, Sergei
