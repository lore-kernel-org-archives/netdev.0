From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 1/2] rhashtable: require max_shift if grow_decision
 defined
Date: Tue, 24 Feb 2015 16:40:03 +0000
Message-ID: <20150224164003.GB21107@casper.infradead.org>
References: <1424794259-30241-1-git-send-email-johunt@akamai.com>
 <1424794259-30241-2-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46557 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbbBXQkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 11:40:06 -0500
Content-Disposition: inline
In-Reply-To: <1424794259-30241-2-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/15 at 11:10am, Josh Hunt wrote:
> If an rhashtable user defines a grow_decision fn they must also define a
> max_shift parameter.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
