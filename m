From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] rtnetlink: fix spelling errors
Date: Mon, 9 Apr 2012 13:27:56 -0700
Message-ID: <20120409132756.32daeaa6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40191 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab2DIU17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 16:27:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor spelling mistakes.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/rtnetlink.h	2012-02-27 08:43:02.400935781 -0800
+++ b/include/net/rtnetlink.h	2012-04-09 13:24:02.705034830 -0700
@@ -41,7 +41,7 @@ static inline int rtnl_msg_family(const
  *	@get_size: Function to calculate required room for dumping device
  *		   specific netlink attributes
  *	@fill_info: Function to dump device specific netlink attributes
- *	@get_xstats_size: Function to calculate required room for dumping devic
+ *	@get_xstats_size: Function to calculate required room for dumping device
  *			  specific statistics
  *	@fill_xstats: Function to dump device specific statistics
  */
@@ -94,7 +94,7 @@ extern void	rtnl_link_unregister(struct
  * 	@fill_link_af: Function to fill IFLA_AF_SPEC with address family
  * 		       specific netlink attributes.
  * 	@get_link_af_size: Function to calculate size of address family specific
- * 			   netlink attributes exlusive the container attribute.
+ * 			   netlink attributes exclusive the container attribute.
  *	@validate_link_af: Validate a IFLA_AF_SPEC attribute, must check attr
  *			   for invalid configuration settings.
  * 	@set_link_af: Function to parse a IFLA_AF_SPEC attribute and modify
