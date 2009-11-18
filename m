From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Wed, 18 Nov 2009 21:57:41 +0100
Message-ID: <20091118205740.GA282@e-circ.dyndns.org>
References: <20091118154313.GE325@e-circ.dyndns.org> <20091118.080849.196755366.davem@davemloft.net> <20091118164126.GF325@e-circ.dyndns.org> <20091118.095716.61189059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:26660 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755458AbZKRU5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 15:57:39 -0500
Content-Disposition: inline
In-Reply-To: <20091118.095716.61189059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2009 at 09:57:16AM -0800, David Miller wrote:
> > This patch allows adding sysfs attribute groups during netdevice registration.
> > The idea is that before the register_netdev call, several calls to
> > netdev_sysfs_add_group can be done. These attributes are accessible (by
> > udev) during the uevent.
> > 
> > Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Patch is corrupted by your email client.  Tab characters have
> been turned into spaces, etc.
Oops. My fault. I did an copy in X ...
Sorry for that.
> 
> Please fix this up and resubmit.
> 
> Thanks.
