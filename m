From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Thu, 23 Dec 2010 00:33:32 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012230029410.16569@pobox.suse.cz>
References: <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz> <20101222.115721.39176015.davem@davemloft.net> <alpine.LNX.2.00.1012230023490.16569@pobox.suse.cz> <20101222.152743.28800942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, vojtech@suse.cz
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101222.152743.28800942.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Dec 2010, David Miller wrote:

> >> > Besides that, any comments on this, please?
> >> 
> >> It's in my backlog, patience is a virtue.
> > 
> > Please just disregard it, it's not needed with newer kernels. Thanks,
> 
> Was it indeed fixed by commit 86bcebafc5e7f5?

Yes, exactly. It just wasn't obvious enough when looking at the code 
(hence my followup patch which hopefully makes the code more readable on 
a first sight).

Thanks and sorry for the noise.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
