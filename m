From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] netfilter: remove deprecated config option
 NF_CT_ACCT
Date: Wed, 30 Jun 2010 14:10:31 +0200
Message-ID: <4C2B3437.6000602@trash.net>
References: <20100629154507.GA5260@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ole@ans.pl
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36893 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab0F3MKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 08:10:33 -0400
In-Reply-To: <20100629154507.GA5260@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> This patch removes deprecated config option NF_CT_ACCT. The default value is set
> to 0 and warning message is put into connbytes_mt_init (connbytes selected
> NF_CT_ACCT to enable it by default).

Thanks, I already have a patch queued in nf-next for this.

