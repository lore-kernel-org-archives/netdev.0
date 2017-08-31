From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dccp: Add handling of IPV6_PKTOPTIONS to
 dccp_v6_do_rcv()
Date: Thu, 31 Aug 2017 11:44:08 -0700 (PDT)
Message-ID: <20170831.114408.429602044118453235.davem@davemloft.net>
References: <20170830090435.58406d1b@dev>
        <20170830.221649.818214075248119092.davem@davemloft.net>
        <d782f2bb-ade5-62ed-f20f-4854e68a2b93@mail.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, dccp@vger.kernel.org
To: tulup@mail.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d782f2bb-ade5-62ed-f20f-4854e68a2b93@mail.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrii <tulup@mail.ru>
Date: Thu, 31 Aug 2017 08:28:01 +0300

> Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv() in
> net/dccp/ipv6.c, similar
> to the handling in net/ipv6/tcp_ipv6.c
> 
> Signed-off-by: Andrii Vladyka <tulup@mail.ru>

Applied.
