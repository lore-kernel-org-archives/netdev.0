From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Tue, 1 Feb 2011 19:23:46 +0200
Message-ID: <20110201172346.GA24392@redhat.com>
References: <20110127193131.GD5228@redhat.com>
 <1296157547.1640.45.camel@localhost.localdomain>
 <20110127200548.GE5228@redhat.com>
 <20110127.130240.104065182.davem@davemloft.net>
 <1296163838.1640.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, steved@us.ibm.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab1BARYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 12:24:04 -0500
Content-Disposition: inline
In-Reply-To: <1296163838.1640.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 01:30:38PM -0800, Shirley Ma wrote:
> On Thu, 2011-01-27 at 13:02 -0800, David Miller wrote:
> > > Interesting. Could this is be a variant of the now famuous
> > bufferbloat then?
> > 
> > Sigh, bufferbloat is the new global warming... :-/ 
> 
> Yep, some places become colder, some other places become warmer; Same as
> BW results, sometimes faster, sometimes slower. :)
> 
> Shirley

Sent a tuning patch (v2) that might help.
Could you try it and play with the module parameters please?

-- 
MST
