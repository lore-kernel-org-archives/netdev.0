From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] tcp_metrics: Network namespace bloat
 reduction v3
Date: Fri, 13 Mar 2015 01:57:38 -0400 (EDT)
Message-ID: <20150313.015738.1931057813270562576.davem@davemloft.net>
References: <87h9tu114z.fsf_-_@x220.int.ebiederm.org>
	<87vbi7fq92.fsf_-_@x220.int.ebiederm.org>
	<87y4n1xzco.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, hannes@stressinduktion.org,
	ddutt@cumulusnetworks.com, vipin@cumulusnetworks.com,
	shmulik.ladkani@gmail.com, dsahern@gmail.com, ja@ssi.bg
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbbCMF5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 01:57:44 -0400
In-Reply-To: <87y4n1xzco.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 13 Mar 2015 00:04:07 -0500

> This is a small pile of patches that convert tcp_metrics from using a
> hash table per network namespace to using a single hash table for all
> network namespaces.

Looks great, series applied, thanks Eric!
