From: Andi Kleen <andi@firstfloor.org>
Subject: Re: large packet loss take2 2.6.31.x
Date: Wed, 11 Nov 2009 22:47:15 +0100
Message-ID: <878wecka3g.fsf@basil.nowhere.org>
References: <81bfc67a0910310721p21046931o9b512cfd0a8a7acb@mail.gmail.com>
	<200910311944.35922.elendil@planet.nl>
	<81bfc67a0911111219m1efff30cr3186987f9dbb3d4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52946 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759390AbZKKVrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 16:47:11 -0500
In-Reply-To: <81bfc67a0911111219m1efff30cr3186987f9dbb3d4d@mail.gmail.com> (Caleb Cushing's message of "Wed, 11 Nov 2009 15:19:54 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caleb Cushing <xenoterracide@gmail.com> writes:
>>
>> I'm attaching the bisection log and a 'good' dmesg output.
>>
>> c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9 is the first bad commit

Just gives fatal: bad object c9fb3ded7a8a6769f3bcb3ef3d9aed61d3e376a9
here on a standard Linus linux-2.6 tree.

It might be also useful if you could describe what kind
of network devices you use and how you determine
the packet loss.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
