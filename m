From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6 addresses.
Date: Thu, 12 Jun 2008 11:47:40 +0200
Message-ID: <f4845fc0806120247j32ebe3c7s55e247a35d0d93e7@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <1213204329-10973-3-git-send-email-juliusv@google.com>
	 <485081E8.80102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:56404 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbYFLJrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 05:47:45 -0400
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id m5C9lgQD031552
	for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 10:47:42 +0100
Received: from wa-out-1112.google.com (wafj37.prod.google.com [10.114.186.37])
	by spaceape7.eur.corp.google.com with ESMTP id m5C9leno028148
	for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 10:47:41 +0100
Received: by wa-out-1112.google.com with SMTP id j37so2763234waf.22
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 02:47:40 -0700 (PDT)
In-Reply-To: <485081E8.80102@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 3:54 AM, Brian Haley <brian.haley@hp.com> wrote:
> You need to use ipv6_addr_copy() with IPv6 addresses.  Some of your other
> patches have this same problem, I found some of them...

Thanks for spotting this, I will convert it in the next version!

Julius

-- 
Google Switzerland GmbH
