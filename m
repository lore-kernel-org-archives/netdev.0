From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 09 Dec 2015 15:03:49 -0500 (EST)
Message-ID: <20151209.150349.1484825444438338042.davem@davemloft.net>
References: <20151209054543.GA7902@ast-mbp.thefacebook.com>
	<20151209125857.GA9900@pox.localdomain>
	<20151209173842.GA18097@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jhs@mojatatu.com, john.fastabend@gmail.com,
	tom@herbertland.com, hannes@stressinduktion.org,
	linville@tuxdriver.com, jesse@kernel.org, anjali.singhai@intel.com,
	netdev@vger.kernel.org, kiran.patil@intel.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbLIUDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 15:03:51 -0500
In-Reply-To: <20151209173842.GA18097@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 9 Dec 2015 09:38:44 -0800

> p4 is a high level language and absolutely not suitable for such purpose.
> bpf as intermediate representation can be generated from p4 or C or other
> language. There is room to innovate in the language definition on top
> and in HW design at the bottom. That's the most flexible model.

+1
