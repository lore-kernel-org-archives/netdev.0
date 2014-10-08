From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: description of dma_cookie cause make xmldocs
 warning
Date: Wed, 08 Oct 2014 09:15:37 -0700
Message-ID: <1412784937.11091.185.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412780019-32475-1-git-send-email-standby24x7@gmail.com>
	 <54355F66.6060204@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Masanari Iida <standby24x7@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, dan.j.williams@intel.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54355F66.6060204@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-08 at 19:59 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 10/08/2014 06:53 PM, Masanari Iida wrote:
> 
> > In commit 7bced397510ab569d31de4c70b39e13355046387,
> 
>     Please also specify that commit's summary line in parens.

Note that this information is useful for backports and bug fixes.

In this particular case (documentation), there is no chance we'll
backport this patch to any prior stable kernel
