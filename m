From: David Miller <davem@davemloft.net>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Wed, 19 Aug 2009 21:17:36 -0700 (PDT)
Message-ID: <20090819.211736.222582824.davem@davemloft.net>
References: <1762204735.01250727555803.JavaMail.root@mail.holmansrus.com>
	<2087985663.21250727676944.JavaMail.root@mail.holmansrus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, khc@pm.waw.pl
To: walt@holmansrus.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751912AbZHTERZ@vger.kernel.org>
In-Reply-To: <2087985663.21250727676944.JavaMail.root@mail.holmansrus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Walt Holman <walt@holmansrus.com>
Date: Wed, 19 Aug 2009 19:21:16 -0500 (CDT)

Fixing the broken CC: list, it's "netdev" not "linux-netdev".

> Since patching to 2.6.30.5 I'm experiencing periodic timeouts on my e100 which is used as my WAN interface on a server/router box. Nothing is reported in any logs and eventually the traffic resumes. It seems to happen at fairly regular intervals, although I've not timed them. The timeouts last for approx. 60-120 seconds and then traffic resumes normally with no hint of what happened. 
> 
> Reverting commit 303d67c288319768b19ed8dbed429fef7eb7c275 allows traffic to flow freely again. Attaching .config & lspci, anything else you need? 
> 
> -Walt
