From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] bridge: Pass net into br_validate_ipv4 and
 br_validate_ipv6
Date: Tue, 29 Sep 2015 20:32:45 +0200
Message-ID: <20150929183245.GB9620@salvia>
References: <87si62f9os.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38750 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935322AbbI2SZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 14:25:52 -0400
Content-Disposition: inline
In-Reply-To: <87si62f9os.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 04:52:51PM -0500, Eric W. Biederman wrote:
> 
> The network namespace is easiliy available in state->net so use it.

Also applied, thanks.
