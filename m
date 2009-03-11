From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: RDS: no freely available protocol specification?
Date: Wed, 11 Mar 2009 01:04:28 +0100
Message-ID: <7iprgolyb7.fsf@lanthane.pps.jussieu.fr>
References: <7i63ihm3pq.fsf@lanthane.pps.jussieu.fr>
	<49B6F348.8010507@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	RDS Devel <rds-devel@oss.oracle.com>
To: Andy Grover <andy.grover@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754272AbZCKAEv@vger.kernel.org>
In-Reply-To: <49B6F348.8010507@oracle.com> (Andy Grover's message of "Tue\, 10 Mar 2009 16\:10\:00 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your reply, Andy.

>> I've tried searching the web, and I cannot find a freely available
>> protocol specification.

> Look in net-next tree, Documentation/networking/rds.txt.

I cannot find a protocol description, let alone a full specification, in
this document.

>> I am wondering whether we wish to encourage the use of proprietary
>> (undocumented) protocols,

> I thought "rough consensus and running code" was the IETF credo?

I'm not the IETF, but it is my understanding that rough consensus is
achieved by writing protocol specifications, and submitting them as
Internet-Drafts.  (While some Internet-Drafts are destined to become
standards track RFCs after IETF consensus has been reached, many are only
submitted in order to stimulate discussion, and some only get submitted so
that they may become Informational RFCs.)

>From what I can gather from the very sparse documentation, RDS in its
current state cannot possibly achieve IETF consensus, for multiple reasons
(many of which I happen to disagree with -- but I'm not the IETF).  Still,
if Oracle find it useful, I'd like to see it published as an informational
RFC.

I'd have no objection to RDS being included in the Linux kernel without
IETF consensus, as long as the protocol is fully documented.

> If you're interested in getting an RFC drafted for RDS, then I invite you
> to start work on one. I also will accept patches to improve the
> documentation.
>
> See how this works?

Andy, please don't bully me.

                                        Juliusz
