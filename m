From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: 3x59x-fix-pci-resource-management.patch
Date: Fri, 07 Aug 2009 14:53:17 +0400
Message-ID: <4A7C079D.8010505@ru.mvista.com>
References: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:49423 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755830AbZHGKwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 06:52:14 -0400
In-Reply-To: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Andrew Morton wrote:

> Guys, I seem to have been sitting on the below patch for, err, three years.

> I generally do this because there's some issue which needs to be
> addressed, but the patch didn't address it right.

    In this case it was different: you just wanted the patch to be verifed 
on an EISA card...

On Mon, 14 Aug 2006 14:31:46 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

 >> ACK, shall I apply this to netdev#upstream ?

Spose so, but let's not go mainline until I've had a chance to test an
EISA card and a cardbus card.

    There was several more comments from you but they all got resolved 
between you and Jeff at the time...

> Can we please have a revisit and work out what we should do with this?

> Thanks.

WBR, Sergei
