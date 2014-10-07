From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 07 Oct 2014 14:51:17 -0400 (EDT)
Message-ID: <20141007.145117.1442458821633299880.davem@davemloft.net>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	<1412702616.11091.143.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQL_6tEhgQE9aCLe-icG4pyS1dMECGhiQ7+OHEao1GXk3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, jesse@nicira.com,
	gerlitz.or@gmail.com, alexander.h.duyck@intel.com,
	john.r.fastabend@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, tgraf@suug.ch, pshelar@nicira.com,
	azhou@nicira.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbaJGSvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:51:20 -0400
In-Reply-To: <CAADnVQL_6tEhgQE9aCLe-icG4pyS1dMECGhiQ7+OHEao1GXk3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 7 Oct 2014 11:15:32 -0700

> but if HW has programmable parser it should be able to take advantage
> of it and UNNECESSARY is an established model.

Strongly disagree.
