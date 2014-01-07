From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter fixes for net
Date: Tue, 07 Jan 2014 18:38:54 -0500 (EST)
Message-ID: <20140107.183854.1098172581398083314.davem@davemloft.net>
References: <1389132819-9697-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389132819-9697-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue,  7 Jan 2014 23:13:37 +0100

> The following patchset contains two patches:
> 
> * fix the IRC NAT helper which was broken when adding (incomplete) IPv6
>   support, from Daniel Borkmann.
> 
> * Refine the previous bugtrap that Jesper added to catch problems for the
>   usage of the sequence adjustment extension in IPVs in Dec 16th, it may
>   spam messages in case of finding a real bug.
> 
> I know it's fairly late, so please let me know if you prefer that I pass
> you these via net-next.

These look fine, thanks Pablo.
