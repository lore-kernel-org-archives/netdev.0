From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: icplus: remove unnecessary code
Date: Fri, 17 Jun 2011 00:03:48 -0400 (EDT)
Message-ID: <20110617.000348.1503899534076260015.davem@davemloft.net>
References: <1308243870-30203-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	peppe.cavallaro@st.com, u.kleine-koenig@pengutronix.de
To: Gregory.Dietsche@cuw.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772Ab1FQEE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:04:58 -0400
In-Reply-To: <1308243870-30203-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Date: Thu, 16 Jun 2011 12:04:30 -0500

> Compile tested.
> remove unnecessary code that matches this coccinelle pattern
> 	if (...)
> 		return ret;
> 	return ret;
> 
> Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>

Applied.
