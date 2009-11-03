From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Tue, 3 Nov 2009 09:33:33 +0000
Message-ID: <20091103093333.GB6718@ff.dom.local>
References: <4AEFDF22.8000405@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Ryousei Takano <ryousei@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp, Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:51652 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267AbZKCJdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:33:33 -0500
Received: by bwz27 with SMTP id 27so7333952bwz.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 01:33:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AEFDF22.8000405@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-11-2009 08:43, Badalian Vyacheslav wrote:
> Hello dear netdev team!
Hello dear BIG Telecom!

> 
> Linux all time go with the times :)
> Network in world go to use 10G technologies. I can test any stress patches in produce system for linux developers :)
> I discharge from out company in 1 December and have 1 month for all tests.
> I believe that linux net dev team do it easy. Need only begin :) Lets do it together :)
> 
> Jarek, you many times help to us fix small problems in HTB, thanks for this!
> All work great!

Really?! As a matter of fact there isn't fully used the last change,
especially this part:

http://marc.info/?l=linux-netdev&m=124453482324409&w=2

And nobody even noticed it for quite a long time. I'm not even sure
Ryousei needs this now for anything but comparing with some better
tool...

Best regards,
Jarek P.

PS: Slavon, (as usual ;-) wrap the lines and don't top post, please.
