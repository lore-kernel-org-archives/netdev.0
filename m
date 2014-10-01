From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] net/dccp/ccid.c: add __init to
 ccid_activate
Date: Wed, 01 Oct 2014 18:34:45 -0400 (EDT)
Message-ID: <20141001.183445.1800881550207439817.davem@davemloft.net>
References: <1412139126-3794-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, gerrit@erg.abdn.ac.uk,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412139126-3794-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 06:52:06 +0200

> ccid_activate is only called by __init ccid_initialize_builtins in same module.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
