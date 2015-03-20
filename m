From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 16:31:54 -0400 (EDT)
Message-ID: <20150320.163154.1895376895384654433.davem@davemloft.net>
References: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAADnVQKyOA7QADk9KOz_-ZFO+WJs2bbRsXZyXXr0sWag4jpOBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anuradhak@cumulusnetworks.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbbCTUb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:31:56 -0400
In-Reply-To: <CAADnVQKyOA7QADk9KOz_-ZFO+WJs2bbRsXZyXXr0sWag4jpOBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Fri, 20 Mar 2015 09:13:56 -0700

> Both reasons look like workaround for user space issues.
> Just keep this fake-down state in userspace.

+1

> so there will be new flag for every application that cannot deal with
> normal down?

+1 +1 +1
