From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: bluetooth-2.6 2009-04-28
Date: Tue, 28 Apr 2009 22:41:44 -0700 (PDT)
Message-ID: <20090428.224144.186877548.davem@davemloft.net>
References: <1240937916.997.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37526
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751979AbZD2Flu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 01:41:50 -0400
In-Reply-To: <1240937916.997.55.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 28 Apr 2009 09:58:36 -0700

> these are three additional patches that should go into the 2.6.30 kernel
> release. The first one fixes a NULL pointer dereference when adding and
> removing sysfs devices for ACL connections. The other two are fixes for
> interoperability regression we introduced when adding full Simple
> Pairing support. A big thank you here goes to the Nokia guys and their
> QA team for testing the crap out of this. There is actually nothing
> simple about Simple Pairing :)

Pulled, thanks.
