From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Wed, 12 Dec 2007 15:57:08 -0600
Message-ID: <47605934.2060604@nortel.com>
References: <475D7901.1040900@nortel.com> <475D7D70.5030502@nortel.com> <47600A6E.8000202@nortel.com> <47601059.8020203@cosmosbay.com> <4760279E.1080203@nortel.com> <47602DD0.8070402@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:39774 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbXLLV54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 16:57:56 -0500
In-Reply-To: <47602DD0.8070402@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> And what is the version of "ip" command you have on this machine ?
> 
> ip -V

iproute2-ss051107

> You may try other versions of this command
> 
> http://devresources.linux-foundation.org/dev/iproute2/download/

They appear to be numbered by kernel version, and the above version is 
the most recent one for 2.6.14.  Will more recent ones (for newer 
kernels) work with my kernel?

Chris
