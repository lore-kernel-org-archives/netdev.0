From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net: add doc for ip_early_demux sysctl
Date: Wed, 12 Jun 2013 15:10:27 -0700 (PDT)
Message-ID: <20130612.151027.1400914250472097012.davem@davemloft.net>
References: <1370948079-26598-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	alexander.h.duyck@intel.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220Ab3FLWK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:10:27 -0400
In-Reply-To: <1370948079-26598-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 11 Jun 2013 18:54:39 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> commit 6648bd7e0e62c0c8c03b (ipv4: Add sysctl knob to control
> early socket demux) introduced such sysctl, but forgot to add
> doc into Documentation/networking/ip-sysctl.txt. This patch adds it.
> 
> Basically I grab the doc from the description of commit 41063e9dd11956f2d285
> (ipv4: Early TCP socket demux.) and the above commit.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thank you.
