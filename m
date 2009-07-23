From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in back trace (regression)
Date: Thu, 23 Jul 2009 10:53:44 -0700 (PDT)
Message-ID: <20090723.105344.244636270.davem@davemloft.net>
References: <20090723000100.d74d6b1c.akpm@linux-foundation.org>
	<20090723.091523.180916751.davem@davemloft.net>
	<20090723105141.5272aee1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: for.poige+bugzilla.kernel.org@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36823
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753644AbZGWRxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 13:53:38 -0400
In-Reply-To: <20090723105141.5272aee1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 23 Jul 2009 10:51:41 -0700

> I wouldn't have thought that pppoe would be affected by tty changes?
> 
> As opposed to pppotty :)

Good point.  So it's unlikely any of the changes we're discussing
will influence this bug.
