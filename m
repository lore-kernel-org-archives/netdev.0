From: David Miller <davem@davemloft.net>
Subject: Re: ip_rt_bug questions.
Date: Mon, 18 Apr 2011 22:04:19 -0700 (PDT)
Message-ID: <20110418.220419.226797064.davem@davemloft.net>
References: <20110418.144909.52209035.davem@davemloft.net>
	<20110418.145023.13728986.davem@davemloft.net>
	<20110418215922.GA17818@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59655
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751650Ab1DSFEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 01:04:54 -0400
In-Reply-To: <20110418215922.GA17818@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 18 Apr 2011 17:59:23 -0400

> On Mon, Apr 18, 2011 at 02:50:23PM -0700, David Miller wrote:
>  
>  > BTW, if you could modify this thing to spit out a stack
>  > trace (probably by using WARN_ON() or similar) that will
>  > probably show us where the bug is coming from.
> 
> Ok, I'll add that, and see if I can reproduce it again.

Thanks a lot Dave.
