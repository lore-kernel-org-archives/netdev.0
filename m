From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Re: v6: faster tree-based sysctl implementation
Date: Tue, 6 Dec 2011 16:11:41 +0200
Message-ID: <CAJL_dMtgP+BqFn3aGVBbGDJ+kMyGiEC_NmDURzh4mU=Jo=qZVA@mail.gmail.com>
References: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Damien Millescamps <damien.millescamps@6wind.com>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54470 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933255Ab1LFOLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 09:11:42 -0500
In-Reply-To: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

time modprobe dummy numdummies=1000FATAL: Error inserting dummy
(/lib/modules/3.2.0-3-generic/kernel/drivers/net/dummy.ko): Operation
not permitted
real	0m0.192suser	0m0.000ssys	0m0.012s
That was on an Ubuntu system.
What are the practical problems you solve with this ?
Name one or more.

You add more code. This is not good. If you reduce the code, then it
will be interesting.
