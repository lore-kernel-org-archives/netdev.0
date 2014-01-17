From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] pf_packet updates
Date: Thu, 16 Jan 2014 16:17:25 -0800 (PST)
Message-ID: <20140116.161725.1579969225701812466.davem@davemloft.net>
References: <1389799536-23750-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaAQAR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:17:26 -0500
In-Reply-To: <1389799536-23750-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 15 Jan 2014 16:25:33 +0100

> Changelog:
> 
> v1->v2:
>  - put assignments under bind lock in patch 1
>  - added 2 more relevant patches
> 
> v2->v3:
>  - made refcnt unsigned in patch 3
>  - rest unchanged

Series applied, thanks Daniel.
