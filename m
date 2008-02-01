From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Patch 2.6.24 1/3]S2io: Support for vlan_rx_kill_vid entry point
Date: Fri, 01 Feb 2008 13:42:04 -0500
Message-ID: <47A367FC.9020707@garzik.org>
References: <Pine.GSO.4.10.10801241312010.3800-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54979 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755890AbYBASmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:42:09 -0500
In-Reply-To: <Pine.GSO.4.10.10801241312010.3800-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur wrote:
> - Added s2io_vlan_rx_kill_vid entry point function for unregistering vlan.
> - Fix to aggregate vlan packets. IP offset is incremented by
>   4 bytes if the packet contains vlan header.
> 
> Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

applied 1-2, patch #3 failed to apply



