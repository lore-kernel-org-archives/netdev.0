From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 2/2] smsc95xx: set MII_BUSY bit to read/write PHY regs
Date: Tue, 13 Nov 2012 17:44:39 +0000
Message-ID: <CAKh2mn4Hm0R5vgOtx+kjjVXh9ucF649cdrXb_VVbRBN47WGr2A@mail.gmail.com>
References: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
	<20121109.160850.901809648224300452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:44281 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab2KMRok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 12:44:40 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so16358eaa.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 09:44:39 -0800 (PST)
In-Reply-To: <20121109.160850.901809648224300452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Steve please let me know why you only submitted patch #2
> of an apparent 2 part series.

My bad being sloppy when formatting the patch for submission, sorry.
The first patch in my rebased tree was one you've already accepted
into net but hadn't pulled into net-next yet.  I just sent the second
one, and I forgot to remove the 2/2 from it.

They don't depend on each other, they're independent bugfixes.

Sorry again for the sloppyness.
