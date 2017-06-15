From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 21:26:36 +0200
Message-ID: <1497554796.2518.7.camel@sipsolutions.net>
References: <20170615092804.19400-1-johannes@sipsolutions.net>
         <20170615.143654.348690059523724510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52444 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750803AbdFOT0j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 15:26:39 -0400
In-Reply-To: <20170615.143654.348690059523724510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-15 at 14:36 -0400, David Miller wrote:
> Johannes these changes look good, please feel free to submit them
> formally.

Yeah, will do, just need to find the time to at least build-test them
(and we had a holiday here today) :)

johannes
