From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Fix warning for token-ring from sysctl checker
Date: Wed, 14 Nov 2007 08:56:20 -0700
Message-ID: <m1r6is253v.fsf@ebiederm.dsl.xmission.com>
References: <20071113072313.GB16842@lixom.net>
	<20071113.211540.97775009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olof@lixom.net, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:43018 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431AbXKNP5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 10:57:12 -0500
In-Reply-To: <20071113.211540.97775009.davem@davemloft.net> (David Miller's
	message of "Tue, 13 Nov 2007 21:15:40 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Olof Johansson <olof@lixom.net>
> Date: Tue, 13 Nov 2007 01:23:13 -0600
>
>> As seen when booting ppc64_defconfig:
>> 
>> sysctl table check failed: /net/token-ring .3.14 procname does not match
> binary path procname
>> 
>> 
>> Signed-off-by: Olof Johansson <olof@lixom.net>
>
> Patch applied, thanks Olof.

No objections but I think we already have this fixed in the -mm tree.

Eric

