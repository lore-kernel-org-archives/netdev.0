From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] tcp: introduce raw access to experimental options
Date: Fri, 16 Nov 2012 13:44:24 -0500 (EST)
Message-ID: <20121116.134424.1929556546744828875.davem@davemloft.net>
References: <1353084898-42264-1-git-send-email-elelueck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, frankbla@de.ibm.com, raspl@de.ibm.com,
	ubacher@de.ibm.com, samudrala@us.ibm.com
To: elelueck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58591 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670Ab2KPSo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:44:26 -0500
In-Reply-To: <1353084898-42264-1-git-send-email-elelueck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Unprivileged access to set and fetch these things?  I don't think
that's a good idea.

Also, your code has a lot of coding style errors.
