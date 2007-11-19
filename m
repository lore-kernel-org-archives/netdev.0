From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.25 6/6] net: consolidate net namespace related proc files creation
Date: Mon, 19 Nov 2007 13:15:19 -0700
Message-ID: <m1lk8uuh48.fsf@ebiederm.dsl.xmission.com>
References: <20071115160150.GA25520@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35748 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbXKSUQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 15:16:49 -0500
In-Reply-To: <20071115160150.GA25520@iris.sw.ru> (Denis V. Lunev's message of
	"Thu, 15 Nov 2007 19:01:50 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@openvz.org> writes:

> net: consolidate net namespace related proc files creation
>
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Looks good to me, and it looks like there are a lot more places
we can use this as more code is converted.

Eric
