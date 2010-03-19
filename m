From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Add PGM protocol support to the IP stack
Date: Fri, 19 Mar 2010 15:26:37 -0700
Message-ID: <4BA3FA1D.8050204@zytor.com>
References: <alpine.DEB.2.00.1003181245050.23010@router.home>	<87tysccjrn.fsf@basil.nowhere.org> <20100319.145336.226782717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, cl@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:47913 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab0CSW0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 18:26:49 -0400
In-Reply-To: <20100319.145336.226782717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2010 02:53 PM, David Miller wrote:
> But I also don't consider what openpbm has to do right now to
> be all that much of a restriction.  You need privileges to
> add the protocol to the kernel, you need privileges to run
> the userspace variant, there is no real difference.

The real difference is if multiplex is needed between multiple
unprivileged users.

	-hpa
