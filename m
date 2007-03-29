From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 14:16:18 -0400
Message-ID: <20070329181617.GA25770@gospo.rdu.redhat.com>
References: <460BE5F0.7070606@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, ctindel@users.sourceforge.net
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030626AbXC2SRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 14:17:50 -0400
Content-Disposition: inline
In-Reply-To: <460BE5F0.7070606@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2007 at 10:14:40AM -0600, Chris Friesen wrote:
> 
> I"m doing some experimenting with a new network driver that receives 
> jumbo frames into multiple separate pages that are then joined together 
> in a single sk_buff using skb_fill_page_desc().
> 
> It behaved fairly well with standard networking, but its behaving 
> strangely with bonding added to the mix.


Can you elaborate on what isn't going well with this driver/hardware?  

