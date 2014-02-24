From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: TX_RING and VLAN : (packet size is too long 1518 > 1514)
Date: Mon, 24 Feb 2014 23:33:36 +0100
Message-ID: <530BC8C0.6040004@redhat.com>
References: <5309D59A.1020304@fokus.fraunhofer.de> <5309FE75.8030802@redhat.com> <530B0AC9.9080003@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jbrouer@redhat.com, netdev@vger.kernel.org
To: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbaBXWdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 17:33:43 -0500
In-Reply-To: <530B0AC9.9080003@fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 10:03 AM, Mathias Kretschmer wrote:
...
> I've manually merged your patch into 3.10.32 since this is what I'm using right now.
>
> Yes, it works here. We can now send full-sized VLAN-tagged frames via TX_RING.

Ok, thanks, I will submit it some time this week, after some more
testing from my side as well.
