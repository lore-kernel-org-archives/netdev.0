From: Kumar Gala <galak@kernel.crashing.org>
Subject: DSA drivers in net/ vs drivers/net/
Date: Tue, 7 Apr 2009 23:58:05 -0500
Message-ID: <53D98710-2AA9-42D8-A478-40B51303678B@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47056 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751715AbZDHE6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 00:58:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert,

Was glancing over the DSA code and was wondering if there was any  
reason we have the actual drivers for the various chips in net/ vs  
drivers/net/dsa/

- k
