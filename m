From: David Miller <davem@davemloft.net>
Subject: Re: [PULL net-next] tipc: kill off struct print_buf/log
Date: Mon, 16 Jul 2012 22:35:46 -0700 (PDT)
Message-ID: <20120716.223546.296761261829921719.davem@davemloft.net>
References: <20120716193801.GA1838@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	erik.hugne@ericsson.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab2GQFft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:35:49 -0400
In-Reply-To: <20120716193801.GA1838@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 16 Jul 2012 15:38:02 -0400

> This is the same eight commits as sent for review last week[1],
> with just the incorporation of the pr_fmt change as suggested
> by JoeP.  There was no additional change requests, so unless you
> can see something else you'd like me to change, please pull.

Pulled, thanks Paul.
