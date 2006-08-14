From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch to add ethtool -g to Spidernet network driver
Date: Mon, 14 Aug 2006 14:02:26 -0400
Message-ID: <44E0BAB2.6090800@pobox.com>
References: <1154792185.3692.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16797 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932612AbWHNSC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 14:02:29 -0400
To: jim@jklewis.com
In-Reply-To: <1154792185.3692.68.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jim Lewis wrote:
> 
> This patch adds ethtool -g (show ring sizes) support to the Spidernet
> network driver.
> 
> Signed-off-by: James K Lewis <jklewis@us.ibm.com>

ACK, but does not apply:


Applying 'Patch to add ethtool -g to Spidernet network driver'

error: patch fragment without header at line 13: @@ -1612,13 +1612,12 @@ 
spider_net_open(struct net_device *netde
error: patch fragment without header at line 31: @@ -2006,6 +2005,9 @@ 
spider_net_setup_netdev(struct spider_ne
error: patch fragment without header at line 47: @@ -441,6 +441,9 @@ 
struct spider_net_card {
error: patch fragment without header at line 63: @@ -130,6 +130,18 @@ 
spider_net_ethtool_set_tx_csum(struct ne
error: patch fragment without header at line 82: @@ -141,5 +153,6 @@ 
struct ethtool_ops spider_net_ethtool_op
fatal: No changes

