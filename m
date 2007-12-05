From: David Miller <davem@davemloft.net>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 22:01:50 -0800 (PST)
Message-ID: <20071204.220150.141230758.davem@davemloft.net>
References: <47544896.7070101@candelatech.com>
	<475451B1.1030006@free.fr>
	<m163zexrqi.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.lezcano@free.fr, greearb@candelatech.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	containers@lists.osdl.org, lkml@rtr.ca,
	shemminger@linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751461AbXLEGBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 01:01:52 -0500
In-Reply-To: <m163zexrqi.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 04 Dec 2007 11:03:01 -0700

> I am confused.  I don't see a path forward that feels right.

Eric, instead of writing a book about how you feel, look
at the simple facts and resolve this quickly.

You added a new key, the namespace, to the looking up of
network objects.

Big deal.

That does not imply a change in licensing for the interfaces
where you added that new aspect of the key to the argument
list.

This symbol licensing decision was not your's to make, so you must
revert the new licensing change you are enforcing upon everyone.

I want a de-GPL patch in my mailbox from you within the next 24 hours
or I will code one up myself.  This is getting beyond rediculious.

My patience is completely gone on this matter, resolve this now.

Thanks.
