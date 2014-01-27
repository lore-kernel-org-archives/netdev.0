From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] AF_PACKET: Add documentation for queue mapping fanout
 mode
Date: Mon, 27 Jan 2014 17:59:18 +0100
Message-ID: <52E69066.5080607@redhat.com>
References: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753580AbaA0Q7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 11:59:32 -0500
In-Reply-To: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2014 05:43 PM, Neil Horman wrote:
> Recently I added a new AF_PACKET fanout operation mode in commit
> 2d36097, but I forgot to document it.  Add PACKET_FANOUT_QM as an available mode
> in the af_packet documentation.  Applies to net-next.
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Daniel Borkmann <dborkman@redhat.com>

Thanks a bunch, Neil.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
