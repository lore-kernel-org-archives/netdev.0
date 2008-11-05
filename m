From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 01/01: netns ct: walk netns list under RTNL
Date: Wed, 05 Nov 2008 03:03:29 -0800 (PST)
Message-ID: <20081105.030329.262482544.davem@davemloft.net>
References: <49117BC8.3010000@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49117BC8.3010000@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 05 Nov 2008 11:56:08 +0100

> following is a single netfilter fix from Alexey Dobriyan,
> fixing an oops caused by a race between netfilter module
> unloading and namespace exit.
> 
> Please apply, thanks.

Applied, thanks Patrick.
