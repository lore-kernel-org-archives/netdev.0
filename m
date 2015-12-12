From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls_iptunnel: add static qualifier to
 mpls_output
Date: Fri, 11 Dec 2015 20:18:09 -0500 (EST)
Message-ID: <20151211.201809.1609331243183993066.davem@davemloft.net>
References: <1449673001-27596-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbbLLBSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 20:18:11 -0500
In-Reply-To: <1449673001-27596-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Wed,  9 Dec 2015 06:56:41 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This gets rid of the following compile warn:
> net/mpls/mpls_iptunnel.c:40:5: warning: no previous prototype for
> mpls_output [-Wmissing-prototypes]
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thank you.
