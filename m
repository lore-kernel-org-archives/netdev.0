From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sat, 14 Nov 2009 08:08:04 +0100
Message-ID: <m3r5s1bn3f.fsf@ursa.amorsen.dk>
References: <200911130701.14847.opurdila@ixiacom.com>
	<4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam>
	<200911131151.31677.opurdila@ixiacom.com>
	<20091113142939.35879efe@s6510> <20091113224043.GP19478@kvack.org>
	<20091113144937.23693bb4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:37526 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922AbZKNHIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Nov 2009 02:08:06 -0500
In-Reply-To: <20091113144937.23693bb4@nehalam> (Stephen Hemminger's message of
	"Fri, 13 Nov 2009 14:49:37 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Then maybe network devices aren't the right layering model. At some
> point the paradigm has to be re-examined.

I'm not quite sure where this becomes a problem. We have 1185 network
interfaces (VLAN's) on one box. Boot time is a problem, but other than
that it works ok. If something like this would help speed up booting,
that would be very nice.


/Benny

