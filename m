From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference at __ip_route_output_key
Date: Mon, 02 Apr 2012 20:34:52 -0400 (EDT)
Message-ID: <20120402.203452.1988294557697559747.davem@davemloft.net>
References: <20120402194056.GA1002@redhat.com>
	<20120402.200711.2234324385609269937.davem@davemloft.net>
	<20120403002200.GA21262@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fedoraproject.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961Ab2DCAe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 20:34:57 -0400
In-Reply-To: <20120403002200.GA21262@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 2 Apr 2012 20:22:00 -0400

> On Mon, Apr 02, 2012 at 08:07:11PM -0400, David Miller wrote:
> 
>  > > We just had this reported. Look familiar to anyone ?
>  > 
>  > If you could unravel the source file and line the OOPS occurs at, I
>  > can look at these kinds of reports much faster.  As it stands, when I
>  > see a Fedora OOPS, it's a long process for me:
> 
> Ok, I'll try and pull these apart for you in future, as I usually
> have the bits for the most recent builds around. 

Thanks a lot Dave.
