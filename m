From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] tcp: introduce a per-route knob for quick ack
Date: Thu, 13 Jun 2013 09:56:55 +0800
Message-ID: <1371088615.10194.0.camel@cr0>
References: <1371030955-6740-1-git-send-email-amwang@redhat.com>
	 <20130612.030224.1420421159493116339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rick.jones2@hp.com,
	stephen@networkplumber.org, tgraf@suug.ch, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757019Ab3FMB56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 21:57:58 -0400
In-Reply-To: <20130612.030224.1420421159493116339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 03:02 -0700, David Miller wrote:
> It is required that you explain, in full detail, and covering
> all of the perspectives, the whole issue of ACK behavior in
> the commit message.
> 
> Otherwise you're making things more difficult for the person who has
> to look at this commit in the future. 

Makes sense! I will give a summary of this in the changelog and resend
it.

Thanks.
