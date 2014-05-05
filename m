From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Need to sock_put on zero csum error
Date: Mon, 05 May 2014 16:23:23 -0400 (EDT)
Message-ID: <20140505.162323.2182243726196148268.davem@davemloft.net>
References: <alpine.DEB.2.02.1405051309280.21835@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293AbaEEUXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 16:23:25 -0400
In-Reply-To: <alpine.DEB.2.02.1405051309280.21835@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 5 May 2014 13:11:57 -0700 (PDT)

> Commit 4068579e1e098fa81d48db9ba4432ab664c58561 introduced

Please provide the commit header line, in parenthesis and double
quotes, after the SHA_ID.  SHA_ID's are ambiguous when changes get
backported into other trees.
