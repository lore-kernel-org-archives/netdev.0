From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Spidernet: add ethtool -S (show statistics)
Date: Fri, 22 Sep 2006 20:13:10 -0400
Message-ID: <45147C16.4020608@pobox.com>
References: <1158865352.30496.29.camel@lewis2.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25304 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964957AbWIWANM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 20:13:12 -0400
To: Jim Lewis <jklewis@us.ibm.com>
In-Reply-To: <1158865352.30496.29.camel@lewis2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK, but patch does not apply:

Applying 'Spidernet: add ethtool -S (show statistics)'

error: patch fragment without header at line 14: @@ -472,6 +472,7 @@ 
spider_net_prepare_rx_descr(struct spide
error: patch fragment without header at line 22: @@ -492,6 +493,7 @@ 
spider_net_prepare_rx_descr(struct spide
error: patch fragment without header at line 30: @@ -721,6 +723,7 @@ 
spider_net_prepare_tx_descr(struct spide
error: patch fragment without header at line 38: @@ -942,6 +945,7 @@ 
spider_net_xmit(struct sk_buff *skb, str
error: patch fragment without header at line 47: @@ -1047,6 +1051,7 @@ 
spider_net_pass_skb_up(struct spider_net
error: patch fragment without header at line 55: @@ -1144,9 +1149,11 @@ 
spider_net_decode_one_descr(struct spide
error: patch fragment without header at line 68: @@ -2112,6 +2119,7 @@ 
spider_net_tx_timeout(struct net_device
error: patch fragment without header at line 82: @@ -438,6 +438,15 @@ 
struct spider_net_options {
error: patch fragment without header at line 98: @@ -464,9 +473,9 @@ 
struct spider_net_card {
error: patch fragment without header at line 115: @@ -27,6 +27,27 @@
error: patch fragment without header at line 143: @@ -143,6 +164,38 @@ 
spider_net_ethtool_get_ringparam(struct
error: patch fragment without header at line 183: @@ -155,5 +208,8 @@ 
struct ethtool_ops spider_net_ethtool_op
fatal: No changes

