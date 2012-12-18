From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 11/11] bridge: Dump vlan information from a bridge port
Date: Tue, 18 Dec 2012 09:03:32 -0800
Message-ID: <20121218090332.2f18f393@nehalam.linuxnetplumber.net>
References: <1355342477-4971-1-git-send-email-vyasevic@redhat.com>
	<1355342477-4971-12-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	john.r.fastabend@intel.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50775 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270Ab2LRRFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 12:05:33 -0500
In-Reply-To: <1355342477-4971-12-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 15:01:17 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> Using the RTM_GETLINK dump the vlan filter list of a given
> bridge port.  The information depends on setting the filter
> flag similar to how nic VF info is dumped.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

I will put these in the bridge tree with other patches that
are being staged for net-next.
