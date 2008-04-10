From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [SCTP]: "list_for_each()" ->
 "list_for_each_entry()" where appropriate.
Date: Thu, 10 Apr 2008 15:36:18 -0700 (PDT)
Message-ID: <20080410.153618.40472986.davem@davemloft.net>
References: <1207856394-19321-3-git-send-email-vladislav.yasevich@hp.com>
	<alpine.LFD.1.00.0804101545570.24254@localhost.localdomain>
	<47FE70C9.3070009@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rpjday@crashcourse.ca, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752896AbYDJWgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 18:36:17 -0400
In-Reply-To: <47FE70C9.3070009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 10 Apr 2008 15:55:53 -0400

> Robert P. J. Day wrote:
> >   actually, if i remember correctly, davem rejected that change as
> > being too disruptive at the moment, no?
>
> this is for 2.6.26, which should be fine.  it was too disruptive for net.26.

Right.
