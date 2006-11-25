From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Sat, 25 Nov 2006 01:27:26 -0700
Message-ID: <m17ixkorrl.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <20061023130113.1430b95d@freekitty>
	<45408397.8070404@fr.ibm.com> <20061026085659.33b4c6dd@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:31464 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1757884AbWKYI25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Nov 2006 03:28:57 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061026085659.33b4c6dd@freekitty> (Stephen Hemminger's message
	of "Thu, 26 Oct 2006 08:56:59 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> 3. Can the virtualized containers be secure? No. we really can't keep
>    hostile root in a container from killing system without going to
>    a hypervisor.

Yes. We can make root in a container have no more powerful than an
ordinary user.  So yes we can make these things secure. 

Eric

