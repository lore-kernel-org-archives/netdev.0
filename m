From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] AFS: Fix VLocation record update wakeup
Date: Fri, 27 Apr 2007 15:27:26 -0700 (PDT)
Message-ID: <20070427.152726.71091045.davem@davemloft.net>
References: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752920AbXD0W1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 18:27:17 -0400
In-Reply-To: <20070427143135.23545.43386.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 27 Apr 2007 15:31:35 +0100

> Fix the wakeup transitions after a VLocation record update completes one way
> or another.  This builds on Dave Miller's partial fix.
> 
> Also move wakeups outside the spinlocked sections.

Applied, thanks David, although a minor nit.

> Signed-Off-By: David Howells <dhowells@redhat.com>

The canonical signoff line does not capitalize Off and By,
I keep fixing this up in your submissions so I figured
I should let you know about it to save me some typing
in the future :-)

