From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] geneve: use network byte order for destination port
 config parameter
Date: Tue, 22 Sep 2015 11:25:05 -0400
Message-ID: <20150922152504.GA18514@tuxdriver.com>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
 <1442606350-11170-1-git-send-email-linville@tuxdriver.com>
 <20150921.162404.1245771010622997220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com, eric.dumazet@gmail.com,
	jesse@nicira.com, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35001 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbIVPaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 11:30:21 -0400
Content-Disposition: inline
In-Reply-To: <20150921.162404.1245771010622997220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 04:24:04PM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 18 Sep 2015 15:59:10 -0400
> 
> > This is primarily for consistancy with vxlan and other tunnels which
> > use network byte order for similar parameters.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> This doesn't apply to any of my trees.  Can you respin it against
> 'net'?  Thanks.

Sure -- sorry about that!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
