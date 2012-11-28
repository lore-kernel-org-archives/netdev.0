From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] bonding: make arp_ip_target parameter checks consistent with sysfs
Date: Wed, 28 Nov 2012 18:34:12 +0100
Message-ID: <87hao91vjf.fsf@nemi.mork.no>
References: <1353759675-30511-1-git-send-email-nikolay@redhat.com>
	<20121128.112316.33060261620694469.davem@davemloft.net>
	<50B63CF4.8070404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net, fubar@us.ibm.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:41250 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab2K1Ret convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:34:49 -0500
In-Reply-To: <50B63CF4.8070404@redhat.com> (Nikolay Aleksandrov's message of
	"Wed, 28 Nov 2012 17:33:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> writes:

> Actually I did see it from kernel/module.c and didn't come up with it
> myself.

Just FYI, running  scripts/checkpatch.pl -f kernel/module.c results in:

total: 27 errors, 65 warnings, 3639 lines checked

NOTE: whitespace errors detected, you may wish to use scripts/cleanpatc=
h or
      scripts/cleanfile

so I'd not use that as a style guide if I were you....



Bj=C3=B8rn
