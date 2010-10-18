From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] secmark: do not return early if there was no error
Date: Tue, 19 Oct 2010 09:48:35 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1010190947480.19779@tundra.namei.org>
References: <20101013202105.15011.60553.stgit@paris.rdu.redhat.com> <4CB86E6A.1040807@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Paris <eparis@redhat.com>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, davem@davemloft.net, jengelh@medozas.de,
	paul.moore@hp.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CB86E6A.1040807@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Oct 2010, Patrick McHardy wrote:

> > ...
> > RIP  [<ffffffffa022117d>] secmark_tg+0x17/0x2e [xt_SECMARK]
> > RSP <ffff880003e03a40>
> > ---[ end trace 9aa5d06a71143e74 ]---
> > 
> > Signed-off-by: Eric Paris <eparis@redhat.com>
> > Acked-by: Paul Moore <paul.moore@hp.com>
> > Acked-by: James Morris <jmorris@namei.org>
> 
> Acked-by: Patrick McHardy <kaber@trash.net>
> 
> I'll leave it up to Dave whether this can still go into 2.6.36.

FYI, I have a copy now in my #next branch, as it's a pre-requisite for 
further patches.


-- 
James Morris
<jmorris@namei.org>
