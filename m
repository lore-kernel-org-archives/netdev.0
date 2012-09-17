From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: GENL: merge GENL_REQUEST and GENL_INITIALIZER
Date: Mon, 17 Sep 2012 15:51:25 -0700
Message-ID: <20120917155125.32fc73a6@nehalam.linuxnetplumber.net>
References: <1347430519-2216-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43421 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755374Ab2IQWvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 18:51:54 -0400
In-Reply-To: <1347430519-2216-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Sep 2012 09:15:19 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> 	Both macros are used together, so better to have
> single define. Update all requests in ipl2tp.c to use the
> new macro.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied
