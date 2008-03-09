From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: PROBLEM: A set of networking related oopses
Date: Sun, 9 Mar 2008 18:31:22 +0100
Message-ID: <20080309173122.GA3339@ami.dom.local>
References: <D04F01C2-03F0-4FBC-933D-62899456BEE9@solitudo.net> <47D26201.2060201@gmail.com> <0CFB0535-DE03-4C13-8EC5-9471CED9B6BE@solitudo.net> <20080308175721.GA3582@ami.dom.local> <2DAAA71E-5F03-41CA-B7E0-5BE4073D14F5@solitudo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tuomas Jormola <tj@solitudo.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:3058 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbYCIR01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 13:26:27 -0400
Received: by fg-out-1718.google.com with SMTP id e21so1598218fga.17
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2008 10:26:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2DAAA71E-5F03-41CA-B7E0-5BE4073D14F5@solitudo.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 09, 2008 at 06:58:47PM +0200, Tuomas Jormola wrote:
...
> there be new oopses, I will replace the old card with a newer Intel 
> gigabit card that I have laying around, and put it in a different PCI 
> slot.

The link I gave you described similar problem just with e1000.
The next message after this thread looks alike (e1000 driver).
So, you shouldn't hurry with this change. Just set this affinity
for both cards and check if it's respected.

Regards,
Jarek P.
