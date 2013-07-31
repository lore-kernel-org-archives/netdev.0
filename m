From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix oops when creating server socket fails
Date: Wed, 31 Jul 2013 15:20:20 -0700 (PDT)
Message-ID: <20130731.152020.219915207900769828.davem@davemloft.net>
References: <1375227995-9581-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ying.xue@windriver.com,
	jon.maloy@ericsson.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34050 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757781Ab3GaWUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 18:20:21 -0400
In-Reply-To: <1375227995-9581-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 30 Jul 2013 19:46:35 -0400

> Problem introduced as of v3.11-rc1~16^2~73^2~12

Please do not refer to commits this way.

Use the format:

	SHA1_ID ("Commit message header line")

thank you.
