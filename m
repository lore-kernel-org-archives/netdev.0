From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!    
      2.6.28
Date: Thu, 8 Jan 2009 22:04:56 -0000 (WET)
Message-ID: <1781.87.196.62.168.1231452296.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <200901082041.58597.denys@visp.net.lb>
    <1059.87.196.62.168.1231451164.squirrel@webmail.decimal.pt>
    <200901082357.13396.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Denys Fedoryschenko" <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly01.isp.novis.pt ([195.23.133.211]:55433 "EHLO
	mailrly01.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbZAHWEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 17:04:35 -0500
In-Reply-To: <200901082357.13396.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've tried before changing this NIC values with ethtool, with 100, 250,
300HZ, with Preempble = server or desktop, and nothing.
Didn't worked in any of those ways.


> Can 100HZ be issue?
> I have hrtimers, tsc now. Tried to change to HPET, nothing changes.
>
>

