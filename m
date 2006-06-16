From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] [patch 0/6] [Network namespace] introduction
Date: Fri, 16 Jun 2006 03:22:15 -0600
Message-ID: <m1zmgdo3p4.fsf@ebiederm.dsl.xmission.com>
References: <20060609210202.215291000@localhost.localdomain>
	<m1mzcdpw3i.fsf@ebiederm.dsl.xmission.com>
	<449274A3.5050304@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:8083 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1750839AbWFPJWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 05:22:41 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <449274A3.5050304@fr.ibm.com> (Daniel Lezcano's message of "Fri,
	16 Jun 2006 11:06:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Eric W. Biederman wrote:
>
>  > Have you seen my previous work in this direction?
>> I know I had a much much more complete implementation.  The only part
>> I had not completed was iptables support and that was about a days
>> more work.
>
> No, I didn't see your work, is it possible to send me a pointer on it or to have
> a patchset of your code ?

It is in my git tree up on kernel.org.  I think it is in my proof-of-concept
branch.

The individual commits tell a tangled tale that is definitely unacceptable
for an upstream merge but the actual result is interesting.

If that isn't enough to find it, tell me and I will track down the details.
It has been a couple months since I posted it during the design discussion
and I'm way overdue for being in bed, tonight.

Eric



