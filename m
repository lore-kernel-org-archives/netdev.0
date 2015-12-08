From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next 2/3] geneve: UDP checksum configuration via
 netlink
Date: Tue, 8 Dec 2015 14:27:04 -0500
Message-ID: <20151208192704.GG3598@tuxdriver.com>
References: <1449599238-4094072-1-git-send-email-tom@herbertland.com>
 <1449599238-4094072-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58817 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbbLHTa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 14:30:28 -0500
Content-Disposition: inline
In-Reply-To: <1449599238-4094072-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 10:27:17AM -0800, Tom Herbert wrote:
> Add support to enable and disable UDP checksums via netlink. This is
> similar to how VXLAN and GUE allow this. This includes support for
> enabling the UDP zero checksum (for both TX and RX).
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Now I can drop this from my todo list... :-)

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
