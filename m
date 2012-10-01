From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv6 net-next] vxlan: virtual extensible lan
Date: Mon, 1 Oct 2012 15:23:05 -0700
Message-ID: <20121001152305.64189076@nehalam.linuxnetplumber.net>
References: <20120927160054.105f4711@nehalam.linuxnetplumber.net>
	<20120927.191200.1483743406607177228.davem@davemloft.net>
	<20121001135719.16062ccb@nehalam.linuxnetplumber.net>
	<20121001.180712.1525189650240917302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, chrisw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60269 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab2JAWXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 18:23:41 -0400
In-Reply-To: <20121001.180712.1525189650240917302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 01 Oct 2012 18:07:12 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 1 Oct 2012 13:57:19 -0700
> 
> > This is an implementation of Virtual eXtensible Local Area Network
> > as described in draft RFC:
> >   http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-02
> > 
> > The driver integrates a Virtual Tunnel Endpoint (VTEP) functionality
> > that learns MAC to IP address mapping. 
> > 
> > This implementation has only been tested with the user-mode TAP
> > based version for Linux, not against other vendors (yet).
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> It doesn't build.
> 
> And I'm not telling you what the build error is, you'll have to do an
> allmodconfig build yourself to see it.
> 
> I want you to get into the habit of doing an allmodconfig build to
> validate your changes because that's the very first thing I'm going to
> do.

Thanks, still waiting for build to finish.
