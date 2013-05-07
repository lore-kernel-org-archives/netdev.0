From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: frag, fix race conditions in LRU list maintenance
Date: Tue, 07 May 2013 05:13:31 -0400 (EDT)
Message-ID: <20130507.051331.942846520697886744.davem@davemloft.net>
References: <20130506093318.679f5557@redhat.com>
	<20130506.110800.1388239604905052651.davem@davemloft.net>
	<51888F93.3030300@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	fw@strlen.de, linux-kernel@vger.kernel.org
To: khlebnikov@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51888F93.3030300@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 07 May 2013 09:22:27 +0400

> Seems like this bug allows to crash kernel remotely.
> Should I send it to stable@ for including into 3.9.y or
> you already have a bunch of patches for it?

I already queued it up for -stable.
