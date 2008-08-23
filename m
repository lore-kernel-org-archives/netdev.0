From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [bisected] Weird sysctl regression
Date: Sat, 23 Aug 2008 23:09:00 +0200
Message-ID: <87od3jo2vn.fsf@natisbad.org>
References: <87fxoyal9j.fsf@natisbad.org>
	<20080823084936.GK28946@ZenIV.linux.org.uk>
	<87wsi7en1m.fsf@natisbad.org>
	<20080823170248.GL28946@ZenIV.linux.org.uk>
	<87ljynd582.fsf@natisbad.org>
	<20080823181651.GM28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:53895 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbYHWVKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 17:10:17 -0400
In-Reply-To: <20080823181651.GM28946@ZenIV.linux.org.uk> (Al Viro's message of
	"Sat, 23 Aug 2008 19:16:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Sat, Aug 23, 2008 at 07:13:49PM +0200, Arnaud Ebalard wrote:
>
>> I already tested 26.27-rc4 and even net-next-2.6 (recently released one
>> based on rc4 with some bug fixes). Problem is still here.
>
> Just to make sure: that's rc4 without any additional patches?

Sorry for the delay. Yes, no additional patches in both cases:

- stock 2.6.27-rc4 from kernel.org
- freshly cloned net-next-2.6 after David's announcement

Cheers,

a+

ps: if you have various ideas you want to test on that issue (additional
    debug, printks, ...), don't hesitate to send me patches ...
