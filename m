From: Dmitry Mishin <dim@openvz.org>
Subject: Re: Network virtualization/isolation
Date: Mon, 4 Dec 2006 19:00:42 +0300
Message-ID: <200612041900.42768.dim@openvz.org>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost> <m1k617u10x.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Daniel Lezcano <dlezcano@fr.ibm.com>,
	devel@openvz.org, Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:40348 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937046AbWLDQBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 11:01:25 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1k617u10x.fsf@ebiederm.dsl.xmission.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 04 December 2006 18:35, Eric W. Biederman wrote:
[skip]
> Where and when you look to find the network namespace that applies to
> a packet is the primary difference between the OpenVZ L2
> implementation and my L2 implementation.
>
> If there is a better and less intrusive while still being obvious
> method I am all for it.  I do not like the OpenVZ thing of doing the
> lookup once and then stashing the value in current and the special
> casing the exceptions.
Why?

-- 
Thanks,
Dmitry.
