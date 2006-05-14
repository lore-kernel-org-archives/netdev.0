From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: 2.6.16.13 e1000 reports incorrect PCI-X bus speed?
Date: Sat, 13 May 2006 17:54:33 -0700
Message-ID: <41b516cb0605131754s1319b3d3lbd27b242b4f1ec37@mail.gmail.com>
References: <4464FB01.6070206@candelatech.com> <4464FF41.7060000@intel.com>
	 <44650B7A.70209@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:28693 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751053AbWENAye convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 May 2006 20:54:34 -0400
Received: by py-out-1112.google.com with SMTP id x31so1096719pye
        for <netdev@vger.kernel.org>; Sat, 13 May 2006 17:54:33 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <44650B7A.70209@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Any idea why 120Mhz is used instead of 133?  It doesn't
> seem to matter in my performance tests, but I am curious...

I think Rick is right, the bus between the bridge on the card and the
e1000s is running at 120Mhz.

- Chris
