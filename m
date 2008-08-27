From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 02:39:31 -0700 (PDT)
Message-ID: <20080827.023931.114686718.davem@davemloft.net>
References: <48B51AE9.5080709@hhs.nl>
	<20080827.020556.90577040.davem@davemloft.net>
	<48B52223.5010606@hhs.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, davej@redhat.com, netdev@vger.kernel.org
To: j.w.r.degoede@hhs.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754436AbYH0Jjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 05:39:35 -0400
In-Reply-To: <48B52223.5010606@hhs.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <j.w.r.degoede@hhs.nl>
Date: Wed, 27 Aug 2008 11:45:07 +0200

> I'm sorry, but I didn't have the feeling I had many options
> left. I've reported a serious performance regression and all the
> answer I've been getting sofar is: "well if that is slow don't do
> that you silly" which is anything but a satisfying answer.

Eric said merely that applications can get better performance by using
the netlink socket dumping interfaces.  It was "for your information",
rather than being suggested as a fix for the bug.

People have given other forms of useful feedback as well, and the bug
seems to be being looked into.
