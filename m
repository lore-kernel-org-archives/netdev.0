From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: 2.6.23-rc2-mm2
Date: Fri, 10 Aug 2007 18:16:49 +0200
Message-ID: <46BC8F71.3070006@googlemail.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Netdev <netdev@vger.kernel.org>, coreteam@netfilter.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:6702 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S941435AbXHJQRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 12:17:35 -0400
Received: by ug-out-1314.google.com with SMTP id j3so461641ugf
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 09:17:33 -0700 (PDT)
In-Reply-To: <20070809224254.11f42716.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton pisze:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm2/
> 

Yet another sysctl table check failed

[   88.949055] Netfilter messages via NETLINK v0.30.
[   89.485399] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   89.491892] sysctl table check failed: /net/netfilter/nf_conntrack_generic_timeout .3.19.13 Missing strategy
[   89.558178] xt_state: Unknown symbol nf_conntrack_untracked
[   89.563942] xt_state: Unknown symbol nf_ct_l3proto_module_put
[   89.569870] xt_state: Unknown symbol nf_ct_l3proto_try_module_get
[   90.852319] NET: Registered protocol family 17

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/
