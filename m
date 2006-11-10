From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [RFT] mv643xxx_eth_start_xmit oops
Date: 10 Nov 2006 20:53:27 -0000
Message-ID: <20061110205327.19468.qmail@farnsworth.org>
References: <20061110191745.GA13783@codepoet.org> <20061110115444.07f58e40@freekitty>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:5647 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S1424420AbWKJUxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 15:53:31 -0500
To: netdev@vger.kernel.org, romieu@fr.zoreil.com,
	Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061110203009.GA9851@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20061110203009.GA9851@electric-eye.fr.zoreil.com> you write:
Ueimor <romieu@fr.zoreil.com> wrote:
> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> [...]
> 
> It seems to propagate a leak from the initial codebase.

Can you provide more detail about the leak?

-Dale
