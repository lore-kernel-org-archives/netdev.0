From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: fix the check when handle RA
Date: Thu, 10 Jul 2014 12:09:10 +0200
Message-ID: <1404986950.14653.1.camel@localhost>
References: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:57938 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752693AbaGJKJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:09:12 -0400
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 2CE5B211A6
	for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 06:09:12 -0400 (EDT)
In-Reply-To: <1404986566-9651-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-07-10 at 18:02 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> d9333196572(ipv6:  Allow accepting RA from local IP addresses.) made the wrong
> check, whether or not to accept RA with source-addr found on local machine, when
> accept_ra_from_local is 0.
> 
> Fixes: d9333196572(ipv6:  Allow accepting RA from local IP addresses.)
> Cc: Ben Greear <greearb@candelatech.com>
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
