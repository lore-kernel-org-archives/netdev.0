From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix copying more bytes than expected in
 sctp_add_bind_addr
Date: Mon, 07 Mar 2016 15:21:23 -0500 (EST)
Message-ID: <20160307.152123.541386738258046959.davem@davemloft.net>
References: <20160307195115.GI31743@localhost.localdomain>
	<CACT4Y+bqn=qWoBiXdV_d1wtedKza4_Nu2uFe4Bui70OPAVGi3A@mail.gmail.com>
	<20160307200008.GJ31743@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, nhorman@tuxdriver.com, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbcCGUV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:21:26 -0500
In-Reply-To: <20160307200008.GJ31743@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Mon, 7 Mar 2016 17:00:08 -0300

> On Mon, Mar 07, 2016 at 08:56:08PM +0100, Dmitry Vyukov wrote:
>> I kept the patch applied.
> 
> Then Dave, please consider applying this patch.

Please submit the patch properly, as a fresh mailing list posting, and
integrating Tested-by: et al. tags as necessary.

Thanks.
