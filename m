From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] net/dccp/proto.c: add __init to
 dccp_mib_init
Date: Wed, 01 Oct 2014 18:34:37 -0400 (EDT)
Message-ID: <20141001.183437.1387283987407270369.davem@davemloft.net>
References: <1412138883-2476-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, gerrit@erg.abdn.ac.uk,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412138883-2476-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 06:48:03 +0200

> dccp_mib_init is only called by __init dccp_init in same module.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
