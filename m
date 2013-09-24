From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] qlge: call ql_core_dump() only if dump memory was
 allocated.
Date: Tue, 24 Sep 2013 11:20:14 -0400 (EDT)
Message-ID: <20130924.112014.306588119328438597.davem@redhat.com>
References: <1379712077-31750-1-git-send-email-malahal@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: malahal@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799Ab3IXPUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 11:20:19 -0400
In-Reply-To: <1379712077-31750-1-git-send-email-malahal@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Malahal Naineni <malahal@us.ibm.com>
Date: Fri, 20 Sep 2013 16:21:17 -0500

> Also changed a log message to indicate that memory was not allocated
> instead of memory not available!
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>

Applied.
