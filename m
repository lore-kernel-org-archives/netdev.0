From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next 0/8] xen-netback/core: packet hashing
Date: Mon, 26 Oct 2015 10:38:50 +0000
Message-ID: <562E02BA.5050301@citrix.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <20151024.045502.1977782979064243034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>, <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.63]:49888 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531AbbJZKiz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 06:38:55 -0400
In-Reply-To: <20151024.045502.1977782979064243034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/10/15 12:55, David Miller wrote:
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Wed, 21 Oct 2015 11:36:17 +0100
> 
>> This series adds xen-netback support for hash negotiation with a frontend
>> driver, and an implementation of toeplitz hashing as the initial negotiable
>> algorithm.
> 
> Ping, I want to see some review from some other xen networking folks.

There's been some review of the front/back protocol (on a different
thread) and some significant changes have been suggested.

David
