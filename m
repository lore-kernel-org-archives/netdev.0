From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: [REGRESSION]linux-2.6.35-rc3 in net/core/dev.c
Date: Wed, 16 Jun 2010 21:27:03 +0200
Message-ID: <201006162127.03412.maciej.rutecki@gmail.com>
References: <201006131625.55481.mitov@issp.bas.bg>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marin Mitov <mitov@issp.bas.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38223 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759415Ab0FPT1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 15:27:09 -0400
In-Reply-To: <201006131625.55481.mitov@issp.bas.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On niedziela, 13 czerwca 2010 o 15:25:54 Marin Mitov wrote:
> Hi all,
> 
> I am using ssh with port redirection to log on host_at_work:
> 
> ssh -L20110:mail:110 host_at_work
> 
> With linux-2.6.35-rc3, when I telnet to localhost I get:
> 
> telnet localhost 20110
> Trying 127.0.0.1...
> telnet: connect to address 127.0.0.1: Connection timed out
> 
> but the connection at host_at_work stays ESTABLISHED
> 

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=16229
for your bug report, please add your address to the CC list in there, thanks!

-- 
Maciej Rutecki
http://www.maciek.unixy.pl
