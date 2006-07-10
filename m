From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: act_api: Fix module leak while flushing actions
Date: Sun, 09 Jul 2006 18:18:42 -0700 (PDT)
Message-ID: <20060709.181842.133422496.davem@davemloft.net>
References: <20060709142043.GN14627@postel.suug.ch>
	<20060709.113858.01310628.davem@davemloft.net>
	<20060709195734.GP14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45495
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964959AbWGJBSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 21:18:01 -0400
To: tgraf@suug.ch
In-Reply-To: <20060709195734.GP14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 9 Jul 2006 21:57:34 +0200

> * David Miller <davem@davemloft.net> 2006-07-09 11:38
> > I'll try to cons something up when I get a chance.  The current
> > situation is too error prone.
> 
> I agree, that's why the new netlink api offers label free
> methods. The transformation patches for 2.6.19 converting
> all netlink users to use the new api will resolved these
> issues.

Awesome, I look forward to seeing those patches.
