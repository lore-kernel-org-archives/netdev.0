From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net-next] l2tp: make local functions static
Date: Fri, 10 Jan 2014 07:25:33 +0000
Message-ID: <52CFA06D.4090409@katalix.com>
References: <20140109222227.3b3b5776@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:46675 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbaAJHZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 02:25:41 -0500
In-Reply-To: <20140109222227.3b3b5776@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/14 06:22, Stephen Hemminger wrote:
> Avoid needless export of local functions
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Acked-by: James Chapman <jchapman@katalix.com>
