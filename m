From: Sparkletone <sparkletone@gmail.com>
Subject: Fwd: Problem accessing a Certain Remote IP with Kernel 2.6.24-rc1
Date: Sat, 3 Nov 2007 15:34:18 -0500
Message-ID: <1855FBA6-5EFE-46E2-A334-AB31C5EDC404@gmail.com>
References: <200711032231.56777.shlomif@iglu.org.il>
Mime-Version: 1.0 (Apple Message framework v912)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: shlomif@iglu.org.il
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:46703 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482AbXKCUeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 16:34:16 -0400
Received: by an-out-0708.google.com with SMTP id b36so151591ana
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2007 13:34:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forwarding this for someone who was getting bounces for some reason.

Begin forwarded message:

> From: Shlomi Fish <shlomif@iglu.org.il>
> Date: November 3, 2007 3:31:56 PM CDT
> To: sparkletone@gmail.com
> Subject: Problem accessing a Certain Remote IP with Kernel 2.6.24-rc1
>
> Hi all!
>
> I hope this mail gets through because last time I checked, I got  
> bounces
> whenever I tried to send email to LKML ("not liked source" for mail).
>
> I've been having a problem with kernel 2.6.24-rc1 on Mandriva  
> Cooker. The
> problem is that after using it for a while connecting through TCP to  
> the
> following remote, Internet IP - 212.143.218.31 - takes a very long  
> time.
>
> Here's what I've learned:
>
> 1. Kernel 2.6.23 seem to exhibit this problem tooa fter a while.
>
> 2. It already happened twice with kernel 2.6.24-rc1.
>
> 3. A different computer on the same Home LAN connected via a NAT/ 
> router has no
> problem with that IP. (At the same time, the Linux computer exhibits  
> the
> problematic behaviour).
>
> 4. I could connect using telnet to port 80 eventually, but it took  
> an awfully
> long time.
>
> 5. I have problem with both HTTP to port 80 and POP.
>
> 6. Restarting the network ("/etc/init.d/network restart") does not  
> help - only
> a reboot.
>
> 7. The network as a whole (Google, etc.) works fine.
>
> I need this IP, because it hosts my POP account and my homepage.
>
> Per Rik van Riel's advice I prepared Ethereal (libpcap) dumps of the
> conversations before ("good") and after ("bad") the problem surfaced:
>
> http://freehackers.org/~shlomif/files/files/www.sf.org-conn-problem/
>
> I'd appreciate if anyone would be able to shed more light on this  
> problem and
> hopefully fix it. Please let me know if there's anything else you  
> need.
>
> Regards,
>
> 	Shlomi Fish
>
> ---------------------------------------------------------------------
> Shlomi Fish      shlomif@iglu.org.il
> Homepage:        http://www.shlomifish.org/
>
> I'm not an actor - I just play one on T.V.

