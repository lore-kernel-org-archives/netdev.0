From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Sun, 1 Oct 2006 17:30:42 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF3C8@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:62373 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932412AbWJAVbL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 17:31:11 -0400
To: Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>In the case above I am concerned about the situation where the
> >>skb->secmark == 0 and there is a IPv4 option (i.e. it is NetLabel
> >>labeled) on the packet.
> 
> It's unfortunate that you cut out the code in your reply.

It's even more unfortunate that you should say this. The proper
thing to do is to simply repaste portions that you feel like you
need to.

Remember, we aren't opponents standing for election this season. :)
