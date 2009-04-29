From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
 sk_buff state
Date: Tue, 28 Apr 2009 22:30:58 -0700 (PDT)
Message-ID: <20090428.223058.119960146.davem@davemloft.net>
References: <20090429040501.GA32074@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dvomlehn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54788
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753090AbZD2FbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 01:31:05 -0400
In-Reply-To: <20090429040501.GA32074@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry, for this to be useful distributions are going to turn it on by
default, and adding 24 bytes to struct sk_buff on 64-bit when we're
trying everything in our power to make it smaller rather than larger
is not acceptable.

It's a useful change, something to keep in one's back pocket when
debugging something, but not for upstream, sorry.
