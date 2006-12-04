From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  v2 04/13] Connection Manager
Date: Mon, 04 Dec 2006 07:45:52 -0800
Message-ID: <ada8xhnk6kv.fsf@cisco.com>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	<20061202224958.27014.65970.stgit@dell3.ogc.int>
	<20061204110825.GA26251@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:33704 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936981AbWLDPqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:46:03 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061204110825.GA26251@2ka.mipt.ru> (Evgeniy Polyakov's message of "Mon, 4 Dec 2006 14:08:26 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Could you convince network core developers that it is not own TCP
 > implementation which will mess with existing one?

I'm not qualified to comment on this...

 > This and a lot of other changes in this driver definitely says you
 > implement your own stack of protocols on top of infiniband hardware.

...but I do know this driver is for 10-gig ethernet HW.

 - R.
