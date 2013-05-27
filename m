From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v9 00/11] vxlan: add ipv6 support
Date: Mon, 27 May 2013 19:00:46 +0800
Message-ID: <1369652446.8181.10.camel@cr0>
References: <1369628193-14925-1-git-send-email-amwang@redhat.com>
	 <87a9ngddfv.fsf@nemi.mork.no> <8761y4dcm7.fsf@nemi.mork.no>
	 <20130527.023039.165030551447378095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757603Ab3E0LA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 07:00:56 -0400
In-Reply-To: <20130527.023039.165030551447378095.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-27 at 02:30 -0700, David Miller wrote:
> 
> And you had the nerve to complain when we were unwilling to merge this
> not-ready garbage into 3.10?!?!  Are you kidding me? 

Please fix the netfilter erorrs too:

http://marc.info/?l=netfilter-devel&m=136849956816787&w=2

which were reported by me two weeks ago, NO ONE cares! Just complaining
about vxlan seems unfair. :)
