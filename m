From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bridge: mdb: add support for extended
 attributes
Date: Fri, 19 Feb 2016 15:26:24 -0500 (EST)
Message-ID: <20160219.152624.1985675317649693405.davem@davemloft.net>
References: <1455623214-2951-1-git-send-email-razor@blackwall.org>
	<20160218.153740.101157132273397459.davem@davemloft.net>
	<56C62ECE.6000900@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: razor@blackwall.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37830 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422953AbcBSU01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:26:27 -0500
In-Reply-To: <56C62ECE.6000900@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 18 Feb 2016 21:51:26 +0100

> I just thought this version is a middle ground between the two solutions and
> still doesn't break user-space while being extensible.

Ok, I'll apply this series, thanks for taking me through your thought
process.
