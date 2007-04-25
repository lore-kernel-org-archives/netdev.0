From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 14:13:01 -0600
Message-ID: <m1ejm8qkky.fsf@ebiederm.dsl.xmission.com>
References: <20070425122924.88391585.akpm@linux-foundation.org>
	<20070425.130011.21926881.davem@davemloft.net>
	<m1irbkqkvp.fsf@ebiederm.dsl.xmission.com>
	<20070425.131009.35662849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:56880 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993036AbXDYUN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:13:56 -0400
In-Reply-To: <20070425.131009.35662849.davem@davemloft.net> (David Miller's
	message of "Wed, 25 Apr 2007 13:10:09 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 25 Apr 2007 14:06:34 -0600
>
>> David for clarity do you happen to know of anyone using binary
>> sysctl values?
>
> None at all.
>
>> In particular is there any reason not to use CTL_UNNUMBERED
>> for new networking sysctls?
>
> Neil said he would send me a patch to do that.

Thanks. I just wanted to be certain I wasn't missing something,
when asking people not to use binary sysctl values.

Eric
