From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: fix IFF_ALLMULTI handling
Date: Tue, 01 Oct 2013 08:07:58 +0200
Message-ID: <87eh851q2p.fsf@dell.be.48ers.dk>
References: <1380576500-8531-1-git-send-email-peter@korsgaard.com>
	<20130930.194950.1406135155659503628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter@korsgaard.com, netdev@vger.kernel.org,
	joseph_chang@davicom.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:34830 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3JAGID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 02:08:03 -0400
Received: by mail-ea0-f170.google.com with SMTP id h14so3148690eak.29
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 23:08:01 -0700 (PDT)
In-Reply-To: <20130930.194950.1406135155659503628.davem@davemloft.net> (David
	Miller's message of "Mon, 30 Sep 2013 19:49:50 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Miller <davem@davemloft.net> writes:

Hi,

 David> Applied, thanks.

Thanks!

 David> It would be so much better if these register values were all
 David> properly documented, one by one, with macros.

Yes, I know. I'll take a look at getting rid of all the magic values.

-- 
Bye, Peter Korsgaard
