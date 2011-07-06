From: David Miller <davem@davemloft.net>
Subject: have to rewind net-next-2.6
Date: Tue, 05 Jul 2011 22:32:37 -0700 (PDT)
Message-ID: <20110705.223237.58087174954909834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab1GFFcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 01:32:39 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p665Wbk4010103
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 22:32:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have to rewind net-next-2.6 back to commit "f8bae99"
in order to get rid of the broken OF "phy-mode" patch
that breaks the build.

Sorry for any inconvenience.
