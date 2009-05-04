From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Temporary IPv6 address asignment
Date: Sun, 03 May 2009 17:21:14 -0700 (PDT)
Message-ID: <20090503.172114.26464142.davem@davemloft.net>
References: <20090503.153428.07349534.davem@davemloft.net>
	<49FE1E71.6090500@poczta.fm>
	<m1skjlrb79.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stlman@poczta.fm, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39231
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753822AbZEDAVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 20:21:20 -0400
In-Reply-To: <m1skjlrb79.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 03 May 2009 16:58:02 -0700

> These are numbers used in the kernel sysctl binary ABI.  You just
> changed them breaking the ABI, when you put NET_IPV6_DESYNC_FACTOR in
> the middle.

In fact adding new sysctl values are totally verbotten these days.
