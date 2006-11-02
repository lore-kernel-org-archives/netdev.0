From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP congestion graphs (2.6.19-rc4)
Date: Thu, 2 Nov 2006 11:58:12 -0800
Message-ID: <20061102115812.1ad27283@freekitty>
References: <20061031.173028.118970335.davem@davemloft.net>
	<20061101052500.GA19676@2ka.mipt.ru>
	<20061031215848.7588d5f0@localhost.localdomain>
	<20061101.214418.74747744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, davidwei79@gmail.com, rhee@eos.ncsu.edu,
	sha2@ncsu.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31638 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752053AbWKBT6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 14:58:43 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061101.214418.74747744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Nov 2006 21:44:18 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 31 Oct 2006 21:58:48 -0800
> 
> > Some basic stuff is on the parent page
> > 	http://developer.osdl.org/shemminger/tcp
> 
> Are you using tcptrace to generate those plots?
> If so are you using xplot or gnuplot to build those
> image files?
> 

Description now up on linux-net
	http://linux-net.osdl.org/index.php/TCP_testing

I use tcpprobe kernel module because you can't directly see congestion
window from packet captures.



-- 
Stephen Hemminger <shemminger@osdl.org>
