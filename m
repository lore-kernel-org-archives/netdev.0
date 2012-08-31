From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH] net: Avoid spinlock recursion
Date: Fri, 31 Aug 2012 21:02:03 +0800
Message-ID: <1346418123.20739.4.camel@cr0>
References: <CAJAFBLCPjjBCmO0vxUeqSKJEkDkuQGF9H9hFRxWgFH92Kpz=VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fubo Chen <fubo.chen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316Ab2HaNCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 09:02:10 -0400
In-Reply-To: <CAJAFBLCPjjBCmO0vxUeqSKJEkDkuQGF9H9hFRxWgFH92Kpz=VA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-27 at 14:52 +0000, Fubo Chen wrote:
> Fixes a bug introduced by commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d.

Hi,

I already sent a patch:
http://patchwork.ozlabs.org/patch/179954/

Thanks!
