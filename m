From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v7 0/9] xen-netback: TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy
Date: Mon, 10 Mar 2014 10:15:53 +0000
Message-ID: <20140310101553.GO19620@zion.uk.xensource.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
 <20140307.160552.282750558679341658.davem@davemloft.net>
 <531B2B3E.5050800@citrix.com>
 <20140308.185759.494043114567727021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <zoltan.kiss@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>, <andrew.bennieston@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3293 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095AbaCJKPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 06:15:55 -0400
Content-Disposition: inline
In-Reply-To: <20140308.185759.494043114567727021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2014 at 06:57:59PM -0500, David Miller wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
> Date: Sat, 8 Mar 2014 14:37:50 +0000
> 
> > Maybe you mixed up mine with that? But that's also not eligible to be
> > applied yet.
> 
> I can always revert the series if there are major objections.

David, I appreciate your speed, but can you revert this series first. I
think this series still needs to undergo review. I believe Ian still
wants to have a look at it but he's travelling at the moment.

Wei.
