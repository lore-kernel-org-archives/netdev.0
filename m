From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/14]: netlink: memory mapped I/O
Date: Fri, 19 Apr 2013 15:51:18 -0400 (EDT)
Message-ID: <20130419.155118.2286345536933919553.davem@davemloft.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 17 Apr 2013 18:46:55 +0200

> The following patches contain an implementation of memory mapped I/O for
> netlink. The implementation is modelled after AF_PACKET memory mapped I/O
> with a few differences:

I like these changes a lot, applied, thanks Patrick!
