From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration changes
Date: Thu, 28 Sep 2006 16:10:49 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609281609560.28355@d.namei>
References: <20060928180326.896170000@hp.com> <20060928180337.570612000@hp.com>
 <Pine.LNX.4.64.0609281547060.28120@d.namei> <451C2AEA.7050608@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-audit@redhat.com, Eric Paris <eparis@redhat.com>,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:26078 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751990AbWI1UKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 16:10:52 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <451C2AEA.7050608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006, Paul Moore wrote:

> Agreed, in fact, as I suspect you have already noticed, this was ripped
> right from that function.  It was private to kernel/auditsc.c making it
> offlimits, but I would have gladly used it instead; making
> audit_log_task_info() public seemed like something that was beyond this
> NetLabel specific patch.

Don't ever be afraid to improve core kernel code :-)




- James
-- 
James Morris
<jmorris@namei.org>
