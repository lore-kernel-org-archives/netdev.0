From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] benet: remove bogus "unlikely" on vlan
 check
Date: Sun, 28 Aug 2011 17:14:39 -0400 (EDT)
Message-ID: <20110828.171439.1664188705577583741.davem@davemloft.net>
References: <1314276651-9138-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab1H1VOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 17:14:48 -0400
In-Reply-To: <1314276651-9138-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 25 Aug 2011 14:50:51 +0200

> Use of unlikely in this place is wrong. Remove it.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

I'll apply this, thanks Jiri.
