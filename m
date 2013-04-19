From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Fri, 19 Apr 2013 16:37:21 -0400 (EDT)
Message-ID: <20130419.163721.2073959342480360942.davem@davemloft.net>
References: <20130419194537.GA1633@kroah.com>
	<20130419.155859.1092595631804890737.davem@davemloft.net>
	<20130419131632.31fce894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab3DSUhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:37:22 -0400
In-Reply-To: <20130419131632.31fce894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 19 Apr 2013 13:16:32 -0700

> I can not get line rate output with pktgen on existing kernels today.

Something is incredibly wrong if this is the case.
