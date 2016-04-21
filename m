From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/3] Feature tweaks/fixes follow-up to GSO
 partial patches
Date: Thu, 21 Apr 2016 15:11:33 -0400 (EDT)
Message-ID: <20160421.151133.384802177814050111.davem@davemloft.net>
References: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbcDUTLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:11:35 -0400
In-Reply-To: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Wed, 20 Apr 2016 10:49:00 -0400

> This patch series is a set of minor fix-ups and tweaks following the GSO
> partial and TSO with IPv4 ID mangling patches.  It mostly is just meant to
> make certain that if we have GSO partial support at the device we can make
> use of it from the far end of the tunnel.
> 
> v2: Added cover page which was forgotten with first submission.
>     Added patch that enables TSOv4 IP ID mangling w/ tunnels and/or VLANs.

Since I already applied the first two patches, I just applied the third one
here by itself.

I hope that's OK.

Thanks.
