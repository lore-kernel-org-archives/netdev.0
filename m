From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 2/3]S2io: Support for add/delete/store/restore
 ethernet addresses
Date: Fri, 31 Aug 2007 09:28:23 -0400
Message-ID: <46D81777.2090700@garzik.org>
References: <Pine.GSO.4.10.10708220206510.22078-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60041 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964960AbXHaN2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:28:25 -0400
In-Reply-To: <Pine.GSO.4.10.10708220206510.22078-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sreenivasa Honnur wrote:
> - Support to add/delete/store/restore 64 and 128 Ethernet addresses for
> Xframe I and Xframe II respectively.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

What is the purpose of this?  We do not support more than one unicast 
MAC address at present...

certainly multicast is different


