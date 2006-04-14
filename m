From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: expose vlan structure to user space
Date: Fri, 14 Apr 2006 13:55:56 -0700 (PDT)
Message-ID: <20060414.135556.91849056.davem@davemloft.net>
References: <4436BB69.3010205@roinet.com>
	<443FA08A.8040900@roinet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5593
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965159AbWDNUzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 16:55:43 -0400
To: dacker@roinet.com
In-Reply-To: <443FA08A.8040900@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Acker <dacker@roinet.com>
Date: Fri, 14 Apr 2006 09:15:54 -0400

> David S. Miller wrote:
>  > I think this really belongs in a portable header file
>  > in glibc somewhere.
> 
> David, while I can try to work with the glibc folks, I don't understand 
> how this patch would be different from what if_ether.h exposes to user 
> space today.  Why is one appropriate and the other not?  I am not trying 
> to be a pain; I am just trying to understand the rationale so that I can 
> explain it to others.

Doing stupid things in the past does not equate to being a reason
to keep doing so in the future.
