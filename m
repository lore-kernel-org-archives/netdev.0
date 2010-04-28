From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 07:33:52 -0400
Message-ID: <1272454432.14068.4.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:40017 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab0D1Ldz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 07:33:55 -0400
Received: by qyk9 with SMTP id 9so21079476qyk.1
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 04:33:54 -0700 (PDT)
In-Reply-To: <1272406693.2343.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-28 at 00:18 +0200, Eric Dumazet wrote:

> Thanks David, I was about to resubmit the cumulative patch ;)

Hrm, i never got the email with your patch on top of Changlis
(the fscking ISP has creative ways of reordering, delaying and also
occassionaly loosing my emails). So all my tests from last
week did not include the extra patch. I will try to make time today
to test with latest net-next which seems to have some extra goodies.
If there is any other patch you want me to try let me know...

cheers,
jamal

