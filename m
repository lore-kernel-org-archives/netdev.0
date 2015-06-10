From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipv6: Fix protocol resubmission
Date: Wed, 10 Jun 2015 15:30:02 -0700 (PDT)
Message-ID: <20150610.153002.976250418413224554.davem@davemloft.net>
References: <55783A1B.3070207@akamai.com>
	<557854BB.1090605@linux-ipv6.org>
	<5578B2C5.7080202@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, thehajime@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com, tom@herbertland.com
To: johunt@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbbFJWaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 18:30:06 -0400
In-Reply-To: <5578B2C5.7080202@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>
Date: Wed, 10 Jun 2015 16:57:25 -0500

> Can you please revert this change?
> 
> commit 0243508edd317ff1fa63b495643a7c192fbfcd92
> Author: Josh Hunt <johunt@akamai.com>
> Date:   Mon Jun 8 12:00:59 2015 -0400
> 
>     ipv6: Fix protocol resubmission

Done, thanks.
