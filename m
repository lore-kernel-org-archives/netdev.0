From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/18] netfilter: IPv6 NAT
Date: Wed, 22 Aug 2012 23:23:53 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208222322060.25423@stinky-local.trash.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
 <20120822.022801.740821969974372752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120822.022801.740821969974372752.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Aug 2012, David Miller wrote:

> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 20 Aug 2012 05:39:48 +0200
>
>> Following is the latest IPv6 NAT patchset, based on -rc2.
>
> Feel free to push patch #1 via the nf tree when give the
> final version of this to Pablo, and you can add my ACK to
> it as well if you like:
>
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, will do. The NAT patches depend on a couple of fixes in Pablo's
latest submission, if you could merge net.git into net-next.git, I can
push them to Pablo without creating conflicts. Thanks!
