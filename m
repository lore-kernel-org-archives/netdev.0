From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] tc: u32: Fix icmp_code off.
Date: Tue, 10 Jul 2012 15:40:23 -0700
Message-ID: <20120710154023.092fdeea@nehalam.linuxnetplumber.net>
References: <20120710185318.075fc257cb6b9a2c8ae66479@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40454 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625Ab2GJWki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 18:40:38 -0400
In-Reply-To: <20120710185318.075fc257cb6b9a2c8ae66479@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jul 2012 18:53:18 +0900
Hiroaki SHIMODA <shimoda.hiroaki@gmail.com> wrote:

> The off of icmp_code is not 20 but 21. Also offmask should be 0 unless
> nexthdr+ is specified.
> 
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Both patches applied
