From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH/RFC 00/10] Transparent proxying patches version 4
Date: Thu, 4 Jan 2007 13:13:27 +0100
Message-ID: <200701041313.27894@nienna>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070103193327.GA8331@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:4232 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964805AbXADMNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 07:13:54 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id D5C4F4C124
	for <netdev@vger.kernel.org>; Thu,  4 Jan 2007 13:13:49 +0100 (CET)
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20070103193327.GA8331@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Wednesday 03 January 2007 20:33, Lennert Buytenhek wrote:
> I'd also love to see the old tproxy API go away entirely.  It was
> always a bit of a pain to use.

  It's gone with these patches: all you need is to bind() to foreign 
addresses, like in the Linux 2.2 days.

-- 
 Regards,
  Krisztian Kovacs
