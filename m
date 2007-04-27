From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] NET: Fix networking compilation errors
Date: Fri, 27 Apr 2007 15:32:00 -0700 (PDT)
Message-ID: <20070427.153200.122619411.davem@davemloft.net>
References: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
	<20070427143145.23545.28816.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757500AbXD0Wbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 18:31:51 -0400
In-Reply-To: <20070427143145.23545.28816.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 27 Apr 2007 15:31:45 +0100

> Fix miscellaneous networking compilation errors.
> 
>  (*) Export ktime_add_ns() for modules.
> 
>  (*) wext_proc_init() should have an ANSI declaration.
> 
> Signed-Off-By: David Howells <dhowells@redhat.com>

Also applied, thanks David.
