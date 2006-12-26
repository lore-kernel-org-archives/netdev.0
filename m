From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/3] chelsio driver changes
Date: Tue, 26 Dec 2006 16:16:30 -0500
Message-ID: <4591912E.60402@pobox.com>
References: <20061215190716.956791000@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41359 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932789AbWLZVQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:16:32 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061215190716.956791000@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> One error path bug fix, and a couple of changes to improve
> receive performance.  The performance is now up to 5+ Gbits/sec
> which is about the limit of the memory/bus on the test systems.

I request a rediff+resend against netdev-2.6.git#upstream, giving 
sufficient time [hours :(] for it to mirror out.

	Jeff



