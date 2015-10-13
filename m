From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next v2 3/4] bridge: vlan: drop unnecessary flush code
Date: Tue, 13 Oct 2015 10:20:15 +0300
Message-ID: <20151013072015.GD28618@colbert.mtl.com>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
 <1444679225-7354-4-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <shm@cumulusnetworks.com>,
	<roopa@cumulusnetworks.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	"Nikolay Aleksandrov" <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0075.outbound.protection.outlook.com ([157.55.234.75]:40627
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752070AbbJMHUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 03:20:24 -0400
Content-Disposition: inline
In-Reply-To: <1444679225-7354-4-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 10:47:04PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>As Ido Schimmel pointed out the vlan_vid_del() code in nbp_vlan_flush is
>unnecessary (and is actually a remnant of the old vlan code) so we can
>remove it.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
