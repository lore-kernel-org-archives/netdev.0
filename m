From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Tue, 12 Apr 2011 16:17:44 -0700 (PDT)
Message-ID: <20110412.161744.27803776.davem@davemloft.net>
References: <bug-32832-10286@https.bugzilla.kernel.org/>
	<20110412161556.0641bdae.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756363Ab1DLXST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:18:19 -0400
In-Reply-To: <20110412161556.0641bdae.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 12 Apr 2011 16:15:56 -0700

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

Stephen Hemminger forwarded this to the list last week, and Eric
Dumazet is actively working on a fix.
