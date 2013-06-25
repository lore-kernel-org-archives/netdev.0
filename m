From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 5/6] rtnetlink: allow using zero MAC
 address in rtnl_fdb_{add,del}
Date: Tue, 25 Jun 2013 16:48:32 -0700 (PDT)
Message-ID: <20130625.164832.2025516831400787366.davem@davemloft.net>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372165316-17647-6-git-send-email-mike.rapoport@ravellosystems.com>
	<20130625093738.2b3e3a0b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mike.rapoport@ravellosystems.com, netdev@vger.kernel.org,
	dlstevens@us.ibm.com, tgraf@suug.ch, xiyou.wangcong@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3FYXsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:48:33 -0400
In-Reply-To: <20130625093738.2b3e3a0b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 25 Jun 2013 09:37:38 -0700

> This is needed, to avoid breaking bridge use of fdb.
> I will just add it after Mike's patches.

Ok, then I expect this series via a pull request from you Stephen.

Thanks.
