From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Tue, 05 Dec 2006 09:14:06 -0800
Message-ID: <adaslfufeox.fsf@cisco.com>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	<20061202224958.27014.65970.stgit@dell3.ogc.int>
	<20061204110825.GA26251@2ka.mipt.ru> <ada8xhnk6kv.fsf@cisco.com>
	<1165249251.32724.26.camel@stevo-desktop>
	<45754DE3.1020505@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:44947 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968476AbWLEROK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 12:14:10 -0500
To: Brice Goglin <Brice.Goglin@ens-lyon.org>
In-Reply-To: <45754DE3.1020505@ens-lyon.org> (Brice Goglin's message of "Tue, 05 Dec 2006 11:45:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Is there really no way to only keep the actual hw infiniband there, move
 > iwarp/rdma drivers in drivers/net/something/ and the core stuff in
 > net/something/ ?

It's definitely possible, but rearranging the source tree hasn't been
a high priority (for me at least).

 - R.
