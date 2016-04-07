From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Backport Security Fix for CVE-2015-8787 to v4.1
Date: Thu, 7 Apr 2016 16:46:28 +0200
Message-ID: <20160407144628.GA1137@salvia>
References: <570600DE.2030001@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kamatam@amazon.com
To: Yuki Machida <machida.yuki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53027 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756453AbcDGOqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 10:46:36 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C6A2515AEA9
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 16:46:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B70A3DA8F7
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 16:46:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B076BDA38E
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2016 16:46:28 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <570600DE.2030001@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2016 at 03:40:30PM +0900, Yuki Machida wrote:
> Hi David,
> 
> I conformed that a patch of CVE-2015-8787 not applied at v4.1.21.
> Could you please apply a patch for 4.1-stable ?
> 
> CVE-2015-8787
> Upstream commit 94f9cd81436c85d8c3a318ba92e236ede73752fc

I'll request again, this time to Sasha Levin to include this in
-stable 4.1.

Thanks.
