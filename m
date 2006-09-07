From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 23:11:27 -0600
Message-ID: <m1ac5ctg5c.fsf@ebiederm.dsl.xmission.com>
References: <54AD0F12E08D1541B826BE97C98F99F1963B59@NT-SJCA-0751.brcm.ad.broadcom.com>
	<m1irk0tw5d.fsf@ebiederm.dsl.xmission.com>
	<20060906175312.7b4d0ddb@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Caitlin Bestler" <caitlinb@broadcom.com>,
	"Kir Kolyshkin" <kir@openvz.org>, devel@openvz.org,
	"Andrey Savochkin" <saw@sw.ru>, alexey@sw.ru,
	"Linux Containers" <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:41891 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1750789AbWIGFM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 01:12:28 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060906175312.7b4d0ddb@localhost.localdomain> (Stephen
	Hemminger's message of "Wed, 6 Sep 2006 17:53:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> The problem with VNIC's is it won't work for all devices (without lots of
> work), and for many device's it requires putting the device in promiscuous
> mode. It also plays havoc with network access control devices.

Which is fine.  If it works it is a cool performance optimization.
But it doesn't stop anything from my side if it doesn't.

Eric

