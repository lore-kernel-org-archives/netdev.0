From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Sat, 21 Nov 2009 12:47:57 +0100
Message-ID: <20091121114755.GA2693@e-circ.dyndns.org>
References: <20091118164126.GF325@e-circ.dyndns.org> <20091118.095716.61189059.davem@davemloft.net> <20091118205952.GB282@e-circ.dyndns.org> <20091118.130859.99831401.davem@davemloft.net> <20091118214226.GA283@e-circ.dyndns.org> <m1vdh6t2y6.fsf@fess.ebiederm.org> <20091120102113.GC282@e-circ.dyndns.org> <m1d43dtavj.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay003.isp.belgacom.be ([195.238.6.53]:24078 "EHLO
	mailrelay003.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753153AbZKULrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 06:47:52 -0500
Content-Disposition: inline
In-Reply-To: <m1d43dtavj.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 08:32:48AM -0800, Eric W. Biederman wrote:
> 
> Kurt Van Dijck <kurt.van.dijck@eia.be> writes:
> 
> >> In this case please look at how I modified the bonding driver to do
> >> what you are trying to do.  That is the conflict in net-next and
> >> I think it was actually less code.
> 
> > It _is_ less code (does a little less too :-) ).
> > It solves the problem anyway. I'll stop with my patch.
> 
> You were just worried about CAN devices and not all network devices
> correct?
Yes, but even not _every_ CAN device. It's driver dependant issue.
> 
> Eric
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
