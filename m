From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [2/5]
Date: Fri, 18 Dec 2009 09:36:05 -0800
Message-ID: <20091218093605.76903fe5@nehalam>
References: <4B2B5A26.8050400@uniroma2.it>
	<4B2B6676.301@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Fabio Ludovici <fabio.ludovici@yahoo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34738 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754023AbZLRRgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 12:36:21 -0500
In-Reply-To: <4B2B6676.301@yahoo.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2009 12:24:38 +0100
Fabio Ludovici <fabio.ludovici@yahoo.it> wrote:

> patch 2/5 : linux-2.6.32/net/sched/sch_netem.c

Could you send with official signed-off-by line please?

Need some style work to match kernel coding style (not a big issue).
And it would be helpful to put in more descriptive variable names
or documentation. But I will try and address these and resubmit,
keeping you as original author.

