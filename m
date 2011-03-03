From: Rick Jones <rick.jones2@hp.com>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Thu, 03 Mar 2011 10:16:08 -0800
Message-ID: <1299176168.2157.14.camel@tardy>
References: <20110225222210.GA3618@tuxdriver.com>
	 <AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
	 <87fwr9jxya.fsf@cruithne.co.teklibre.org>
	 <AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
	 <8739n9ii7z.fsf@cruithne.co.teklibre.org>
	 <AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp@mail.gmail.com>
	 <87tyfph2az.fsf@cruithne.co.teklibre.org>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sedat.dilek@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net,
	linux-kernel@vger.kernel.org
To: Dave =?ISO-8859-1?Q?T=E4ht?= <d@taht.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:45325 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758616Ab1CCSQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 13:16:16 -0500
In-Reply-To: <87tyfph2az.fsf@cruithne.co.teklibre.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For wireless routers and cable home gateways especially, this research
> shows that the total un-managed buffers in your system should be less
> than 32.

Would it be a good thing to start describing these queues not so much in
terms of packets but in terms of delay (or bandwidth X delay)?

Constants tend to live longer than they should, no matter how noble in
birth.

rick jones

