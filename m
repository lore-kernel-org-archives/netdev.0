From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: PATCH: fix cut/paste error in TCPPROBE
Date: Fri, 22 Sep 2006 10:01:06 -0700
Message-ID: <20060922100106.2e128bf5@dxpl.pdx.osdl.net>
References: <20060922144710.GB26719@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34272 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932603AbWIVRB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 13:01:56 -0400
To: Grant Grundler <grundler@parisc-linux.org>
In-Reply-To: <20060922144710.GB26719@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 08:47:10 -0600
Grant Grundler <grundler@parisc-linux.org> wrote:

> Fix cut/paste error in TCPPROBE help text.
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> 
> 
> --- a/net/Kconfig
> +++ b/net/Kconfig
> @@ -231,7 +231,7 @@ config NET_TCPPROBE
>  	TCP congestion avoidance modules. If you don't understand
>  	what was just said, you don't need it: say N.
>  
> -	Documentation on how to use the packet generator can be found
> +	Documentation on how to use TCP connection probing can be found
>  	at http://linux-net.osdl.org/index.php/TcpProbe
>  
>  	To compile this code as a module, choose M here: the

Thanks...
