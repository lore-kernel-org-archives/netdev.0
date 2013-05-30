From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2013-05-29b
Date: Thu, 30 May 2013 15:53:59 -0700 (PDT)
Message-ID: <20130530.155359.2022430388757359040.davem@davemloft.net>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842Ab3E3WyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 18:54:00 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed, 29 May 2013 10:10:30 +0200

> The only real behavioural change in this batch is the broadcast overhead
> reduction on non-wireless interfaces brought by Matthias Schiffer.
> 
> The rest is made up by code cleanups and refactoring.
> 
> Two highlights on the refactoring are the introduction of
> netdev_alloc_skb_ip_align() to avoid to deal with NET_IP_ALIGN manually and the
> introduction of the eth_hdr() wherever it was possible in order to improve
> readability.
> 
> Please pull or let me know of any problem.
 ...
> The following changes since commit 06ecf24bdf2b7afc6c8fd13de6dba2a96dd331b6:
> 
>   net: Fix build warnings after mac_header and transport_header became __u16. (2013-05-28 13:15:50 -0700)
> 
> are available in the git repository at:
> 
>   git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

Pulled, thanks Antonio.
