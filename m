From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3 v7] changes to make ipv4 routing table
 aware of next-hop link status
Date: Wed, 24 Jun 2015 02:37:52 -0700 (PDT)
Message-ID: <20150624.023752.1728293911019047923.davem@davemloft.net>
References: <1435081538-1620-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com,
	sfeldma@gmail.com, alexander.duyck@gmail.com,
	hannes@stressinduktion.org, stephen@networkplumber.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbFXJ0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 05:26:01 -0400
In-Reply-To: <1435081538-1620-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Tue, 23 Jun 2015 13:45:35 -0400

> This series adds the ability to have the Linux kernel track whether or
> not a particular route should be used based on the link-status of the
> interface associated with the next-hop.  

Kernel bits applied, thanks Andy.
