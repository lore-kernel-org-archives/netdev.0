From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] AF_PACKET: Add documentation for queue mapping fanout mode
Date: Mon, 27 Jan 2014 13:48:01 -0800
Message-ID: <87d2jdqepa.fsf@tassilo.jf.intel.com>
References: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21343 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753170AbaA0VsW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 16:48:22 -0500
In-Reply-To: <1390840984-22246-1-git-send-email-nhorman@tuxdriver.com> (Neil
	Horman's message of "Mon, 27 Jan 2014 11:43:04 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> writes:

> Recently I added a new AF_PACKET fanout operation mode in commit
> 2d36097, but I forgot to document it.  Add PACKET_FANOUT_QM as an available mode
> in the af_packet documentation.  Applies to net-next.

Please also send a man page patch.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
