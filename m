From: David Miller <davem@davemloft.net>
Subject: Re: [take6 0/3] kevent: Generic event handling mechanism.
Date: Wed, 09 Aug 2006 01:20:45 -0700 (PDT)
Message-ID: <20060809.012045.21594448.davem@davemloft.net>
References: <11551105592821@2ka.mipt.ru>
	<20060809.005856.104034268.davem@davemloft.net>
	<20060809080754.GA29783@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51136
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965103AbWHIIU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 04:20:57 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060809080754.GA29783@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 12:07:57 +0400

> So you want to review kevent core only at the first point and postpone
> network AIO and the rest implementation after core is correct.

That's the idea

> Should I remove poll/timer notifications too?

That can stay
