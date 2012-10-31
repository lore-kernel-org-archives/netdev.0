From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net PATCH V2] net: fix divide by zero in tcp algorithm illinois
Date: Wed, 31 Oct 2012 23:15:59 +0100
Message-ID: <1351721759.3494.73.camel@localhost>
References: <20121031124318.30915.32293.stgit@dragon>
	 <20121031134836.16b31625@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Petr Matousek <pmatouse@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24773 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759307Ab2JaWQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 18:16:03 -0400
In-Reply-To: <20121031134836.16b31625@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-31 at 13:48 -0700, Stephen Hemminger wrote:
> On Wed, 31 Oct 2012 13:45:32 +0100
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > Reading TCP stats when using TCP Illinois congestion control algorithm
> > can cause a divide by zero kernel oops.
[...]
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

When DaveM is without power, people even have/get time to review and ack
my patches ;-). Thanks Stephen and Eric.

--Jesper
