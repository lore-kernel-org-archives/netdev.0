From: =?utf-8?B?amVzc2VcKOW7uuiIiFwp?= <jesse@icplus.com.tw>
Subject: Re: [PATCH 2/2] ipg: redundancy with mii.h
Date: Tue, 23 May 2006 14:50:25 +0800
Message-ID: <01ca01c67e35$2b78c7a0$4964a8c0@icplus.com.tw>
References: <1146506939.23931.2.camel@localhost> <20060501231206.GD7419@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605020945010.4066@sbz-30.cs.Helsinki.FI> <20060502214520.GC26357@electric-eye.fr.zoreil.com> <20060502215559.GA1119@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605030913210.6032@sbz-30.cs.Helsinki.FI> <20060503233558.GA27232@electric-eye.fr.zoreil.com> <1146750276.11422.0.camel@localhost> <20060504235549.GA9128@electric-eye.fr.zoreil.com> <446F840E.3020808@cantab.net> <20060521101620.GA28210@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Pekka Enberg" <penberg@cs.helsinki.fi>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<david@pleyades.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr45.hinet.net ([168.95.4.145]:10381 "EHLO msr45.hinet.net")
	by vger.kernel.org with ESMTP id S1751101AbWEWGv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 02:51:29 -0400
To: "Francois Romieu" <romieu@fr.zoreil.com>,
	"David Vrabel" <dvrabel@cantab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear All:

I had tested the following patch of IP1000A
http://www.fr.zoreil.com/people/francois/misc/20060521-2.6.17-rc4-git-ip1000-test.patch

It works fine. We will discuss this driver with our members see if there are
anything need to add or modify.
Thanks for everybody's effort for our IP1000A.

Would anybody need some piece of IP1000A, please give me your address, we
will send some of it to you.
Thanks!

If any problem, please feel free to contact me. jesse@icplus.com.tw

Best Regards,
Jesse

----- Original Message ----- 
From: "Francois Romieu" <romieu@fr.zoreil.com>
To: "David Vrabel" <dvrabel@cantab.net>
Cc: "Pekka Enberg" <penberg@cs.helsinki.fi>; <linux-kernel@vger.kernel.org>;
<netdev@vger.kernel.org>; <david@pleyades.net>; <jesse@icplus.com.tw>
Sent: Sunday, May 21, 2006 6:16 PM
Subject: Re: [PATCH 2/2] ipg: redundancy with mii.h


David Vrabel <dvrabel@cantab.net> :
[...]
> 0007-ipg-plug-leaks-in-the-error-path-of-ipg_nic_open.txt broke receive
> since it was skipping the initialization of the Rx buffers.  Patch
attached.

Oops. Applied to branch netdev-ipg of
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

(please include the '-p' option in future invocation of diff)

I have put an updated patch against 2.6.17-rc4 for the whole driver at
http://www.fr.zoreil.com/people/francois/misc/20060521-2.6.17-rc4-git-ip1000-test.patch

-- 
Ueimor

