From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 30 Nov 2015 22:51:04 -0500 (EST)
Message-ID: <20151130.225104.674602151535346425.davem@davemloft.net>
References: <20151129.222243.2290113258075462913.davem@davemloft.net>
	<C40BE8378EF49C44B9184714DBC8EF2993A70447@ORSMSX115.amr.corp.intel.com>
	<CALx6S34vso438+85ggvzkkCQBPRA7f6tHv1qtwVqq=tuxG=uJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jesse@kernel.org, netdev@vger.kernel.org, kiran.patil@intel.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbLADvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 22:51:07 -0500
In-Reply-To: <CALx6S34vso438+85ggvzkkCQBPRA7f6tHv1qtwVqq=tuxG=uJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 30 Nov 2015 13:48:36 -0800

> Please look at how CHECKSUM_COMPLETE interface works. Description is
> in sk_buff.h or
> http://people.netfilter.org/pablo/netdev0.1/papers/UDP-Encapsulation-in-Linux.pdf.

+1
