From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: sctp: sctp_verify_init: clean up mandatory
 checks and add comment
Date: Tue, 27 Aug 2013 15:59:42 +0200
Message-ID: <521CB0CE.3000806@redhat.com>
References: <1377609830-10193-1-git-send-email-dborkman@redhat.com> <20130827134302.GB7619@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957Ab3H0N7t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 09:59:49 -0400
In-Reply-To: <20130827134302.GB7619@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2013 03:43 PM, Neil Horman wrote:

> nit: If we're making this easier to review, I think the above would be easier to
> read if it said:
> Note: Initial TSN is also mandatory, but is not checked here since the valid
> range is 0..2**(32-1)

Ok, will send a v2 in a moment.
