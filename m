From: Brice Goglin <brice@myri.com>
Subject: Re: [patch 06/18] PCI-X/PCI-Express read control interfaces: use
 them in myrinet
Date: Tue, 14 Aug 2007 07:49:17 +0200
Message-ID: <46C1425D.6030606@myri.com>
References: <200708102105.l7AL5H0a008960@imap1.linux-foundation.org> <46C13DE5.2070107@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	peter.oruba@amd.com, rolandd@cisco.com,
	shemminger@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1797 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S942192AbXHNFsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:48:23 -0400
In-Reply-To: <46C13DE5.2070107@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> akpm@linux-foundation.org wrote:
>> From: "Peter Oruba" <peter.oruba@amd.com>
>>
>> These driver changes incorporate the proposed PCI-X / PCI-Express
>> read byte
>> count interface.  Reading and setting those valuse doesn't take place
>> "manually", instead wrapping functions are called to allow quirks for
>> some
>> PCI bridges.
>>
>
> I presume Brice will resend this one to me, next time he pushes...


Ok, I'll take care of it.

Brice

