From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v3 13/13] bonding: pr_debug instead of pr_warn
 in bond_arp_send_all
Date: Wed, 28 Aug 2013 18:22:34 +0200
Message-ID: <20130828162234.GK1992@redhat.com>
References: <1377705842-8276-1-git-send-email-vfalico@redhat.com>
 <1377705842-8276-14-git-send-email-vfalico@redhat.com>
 <1377706548.1928.16.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753913Ab3H1QXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 12:23:51 -0400
Content-Disposition: inline
In-Reply-To: <1377706548.1928.16.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 09:15:48AM -0700, Joe Perches wrote:
...snip...
>On Wed, 2013-08-28 at 18:04 +0200, Veaceslav Falico wrote:
...snip...
>> v2: new patch
>> v3: no change
>
>Hi Veaceslav:

Hi Joe,

>This changelog bit maybe is better placed below the ---

Yep, got it, will modify the next version (in case there will be one -
hopefully it's not a reason to resend the whole patchset - though if anyone
insists I can easily do it).

Thanks for the input!
