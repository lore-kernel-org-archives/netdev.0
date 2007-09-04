From: john@BlueSkyTours.com
Subject: Re: r8169: slow samba performance
Date: Tue, 4 Sep 2007 14:04:13 -0600 (MDT)
Message-ID: <Pine.SOC.4.64.0709041402130.871@katana>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca>
 <46CC9290.3040501@gmail.com> <Pine.SOC.4.64.0708271631330.871@katana>
 <20070903210322.GB4444@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Bruce Cole <bacole@gmail.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat1.blueskytours.com ([12.96.192.180]:54074 "HELO
	volcano.blueskytours.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1753316AbXIDUEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 16:04:14 -0400
In-Reply-To: <20070903210322.GB4444@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 3 Sep 2007, Francois Romieu wrote:

> john@BlueSkyTours.com <john@BlueSkyTours.com> :
> [...]
>> I have had abysmal performance trying to remotely run X apps via ssh on a
>> computer with a RTL8111 NIC.  Saw this message and decided to give this
>> patch a try --- success!  Much, much better.
>
> Can you give a try to:
>
> http://www.fr.zoreil.com/people/francois/misc/20070903-2.6.23-rc5-r8169-test.patch
>
> or just patches #0001 + #0002 at:
>
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.23-rc5/r8169-20070903/


20070903-2.6.23-rc5-r8169-test.patch applied against 2.6.23-rc5 works fine.
Performance is acceptable.

Would you like me to *just* try patches 1 & 2, to help narrow down anything?

Thanks,

John

