From: Andy Grover <andy.grover@oracle.com>
Subject: Re: RDS: no freely available protocol specification?
Date: Tue, 10 Mar 2009 16:10:00 -0700
Message-ID: <49B6F348.8010507@oracle.com>
References: <7i63ihm3pq.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	RDS Devel <rds-devel@oss.oracle.com>
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:38033 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbZCJXKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 19:10:20 -0400
In-Reply-To: <7i63ihm3pq.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
> I am a little worried about the Reliable Datagram Sockets (RDS), which are
> currently in the process of being merged into the kernel.  I've checked the
> latest Interned-Drafts index, I've tried searching the web, and I cannot
> find a freely available protocol specification.  (I've been unable to check
> the documentation section of the oss.oracle.com site, which requires
> a password with no way to register visible to my tired eyes.)

Look in net-next tree, Documentation/networking/rds.txt.

> I am wondering whether we wish to encourage the use of proprietary
> (undocumented) protocols, and I wish that the kernel crowd should really
> try to put some pressure on the Oracle guys to get the RDS protocol spec
> published as an RFC, or at the very least submitted as an Internet Draft,
> before it is released as part of the Linux kernel.

I thought "rough consensus and running code" was the IETF credo? We've
provided running code, some documentation, and an active maintainer and
mailing list. If you're interested in getting an RFC drafted for RDS,
then I invite you to start work on one. I also will accept patches to
improve the documentation.

See how this works?

Regards -- Andy

