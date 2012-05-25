From: lejeczek <peljasz@yahoo.co.uk>
Subject: Re: on the the two IPs unreachable if second interface is up
Date: Fri, 25 May 2012 16:35:16 +0100
Message-ID: <4FBFA6B4.6090807@yahoo.co.uk>
References: <4FBFA172.2060604@yahoo.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm2.bullet.mail.ukl.yahoo.com ([217.146.183.219]:43250 "HELO
	nm2.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752896Ab2EYPfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 11:35:18 -0400
In-Reply-To: <4FBFA172.2060604@yahoo.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here is something potentially interesting!
when I arping the BOX's public IP from a system/client of 
the private subnet I get replied with a mac of the BOX's 
second(private) interface :-[
could this be normal?

On 25/05/12 16:12, lejeczek wrote:
> hello everybody
>
> apologies if this may feel off the topic, I was hoping 
> some net experts could shed some lights on some peculiar 
> symptoms I experience with one linux box
>
> a BOX has two net interfaces, a public and private one
> public IP is reachable from/via the Internet just fine
> public IP is not reachable from the same private network 
> the BOX's second interface is on
> public IP becomes reachable to private subnet immediately 
> after second(private) interface was turned down
> BOX's firewall whether on or off makes no difference
>
> this is the most peculiar problem of this nature I've ever 
> experienced
>
> the goal is simple, have other systems on the same private 
> subnet as the BOX's second interface to be able to talk to 
> the BOX's public IP
> default gateway for the private subnet is a separate 
> another system.
>
> any suggestions as to how to troubleshoot it I would very! 
> much appreciate
> many thanks!
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
>
