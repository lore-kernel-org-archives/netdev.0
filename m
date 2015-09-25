From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] l2tp: module autoloading
Date: Fri, 25 Sep 2015 12:28:38 -0700 (PDT)
Message-ID: <20150925.122838.1734744239428133492.davem@davemloft.net>
References: <20150924043333.231895827@networkplumber.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933145AbbIYT2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 15:28:39 -0400
In-Reply-To: <20150924043333.231895827@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 23 Sep 2015 21:33:33 -0700

> With L2TP it was necessary to manually load modules
> which is a nuisance and not required with other tunneling
> protocols. This set of patches adds the aliases and module
> load hook to get rid of the necessity of modprobing.

Series applied, thanks Stephen.
