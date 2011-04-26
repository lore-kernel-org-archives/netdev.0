From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dsa/mv88e6131: fix unknown multicast/broadcast forwarding on mv88e6085
Date: Tue, 26 Apr 2011 21:08:51 +0200
Message-ID: <87sjt43k58.fsf@macbook.be.48ers.dk>
References: <1303818341-13839-1-git-send-email-jacmet@sunsite.dk>
	<20110426145740.GL1897@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51668 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab1DZTI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 15:08:56 -0400
Received: by eyx24 with SMTP id 24so297227eyx.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 12:08:54 -0700 (PDT)
In-Reply-To: <20110426145740.GL1897@wantstofly.org> (Lennert Buytenhek's
	message of "Tue, 26 Apr 2011 16:57:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Lennert" == Lennert Buytenhek <buytenh@wantstofly.org> writes:

Hi,

 >> The 88e6085 has a few differences from the other devices in the port
 >> control registers, causing unknown multicast/broadcast packets to get
 >> dropped when using the standard port setup.
 >> 
 >> At the same time update kconfig to clarify that the mv88e6085 is now
 >> supported.
 >> 
 >> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

 Lennert> Assuming that you've tested this.. :)

Yes, this time with multicast as well *red ears* ;)

Thanks.

-- 
Bye, Peter Korsgaard
