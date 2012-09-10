From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] iproute2: add libgenl files
Date: Mon, 10 Sep 2012 09:56:07 -0700
Message-ID: <20120910095607.1dafb2ac@nehalam.linuxnetplumber.net>
References: <1347097705-2906-1-git-send-email-ja@ssi.bg>
	<1347097705-2906-2-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43258 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751076Ab2IJQ4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:56:37 -0400
In-Reply-To: <1347097705-2906-2-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  8 Sep 2012 12:48:24 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> +static int libgenl_parse_getfamily(struct nlmsghdr *nlh)

I prefer just using 'genl' rather than 'libgenl' here. Shorter variable
names are clearer.
