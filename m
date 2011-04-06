From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 32832] New: shutdown(2) does not fully shut down socket
 any more
Date: Wed, 06 Apr 2011 16:48:05 -0700 (PDT)
Message-ID: <20110406.164805.193714589.davem@davemloft.net>
References: <20110406160713.7ff48ef1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54086
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756761Ab1DFXsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 19:48:42 -0400
In-Reply-To: <20110406160713.7ff48ef1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 6 Apr 2011 16:07:13 -0700

> Begin forwarded message:
> 
> Date: Wed, 6 Apr 2011 22:42:39 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 32832] New: shutdown(2) does not fully shut down socket any more
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=32832
> 
>            Summary: shutdown(2) does not fully shut down socket any more
 ...
> 
> In 2.6.35 and earlier, shutdown(2) will fully remove a socket. This does not
> appear to be true any more and is causing software to misbehave.
> 

This is already being discussed:

http://marc.info/?l=linux-netdev&m=130176733401613&w=2
