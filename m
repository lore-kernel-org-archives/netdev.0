From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Fri, 27 Nov 2009 13:07:53 -0500
Message-ID: <81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
	 <20091124111946.GA7883@ff.dom.local>
	 <81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
	 <20091125191105.GA3167@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:56073 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbZK0SHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 13:07:49 -0500
In-Reply-To: <20091125191105.GA3167@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.32-rc8 seemed to be affected (guess. because my net didn't come up
on reboot. further testing will likely verify) also during reboots I
found out that the version I've been thinking is good is afflicted. I
supposed maybe I should try bisecting again? starting with that point.
not sure it'll do us much good if that version was able to slip by for
so long. I really hate intermittent bugs.


-- 
Caleb Cushing

http://xenoterracide.blogspot.com
