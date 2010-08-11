From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6] bridge: allow hub-like behaviour
Date: Wed, 11 Aug 2010 12:07:41 -0400
Message-ID: <20100811120741.27e13248@s6510>
References: <20100811144017.GA2625@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48810 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327Ab0HKQHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 12:07:46 -0400
In-Reply-To: <20100811144017.GA2625@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NO. unnecessary

Already possible, without patch. Just set the hold time
on the bridge to 0!
