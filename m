From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates
Date: Mon, 25 Feb 2008 18:36:26 -0500
Message-ID: <47C350FA.7060700@garzik.org>
References: <OF5F5F5698.07AB615F-ON652573F6.00142D8A-652573F6.00147DC9@in.ibm.com> <8A71B368A89016469F72CD08050AD334026D652F@maui.asicdesigners.com> <47C34838.3040502@garzik.org> <200802260134.02075.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
To: Marin Mitov <mitov@issp.bas.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33202 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755178AbYBYXg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 18:36:28 -0500
In-Reply-To: <200802260134.02075.mitov@issp.bas.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marin Mitov wrote:
> On Tuesday 26 February 2008 12:59:04 am you wrote:
>> Divy Le Ray wrote:
>>>> From: "Divy Le Ray" <divy@chelsio.com>
>>>> Date: Wed, 20 Feb 2008 21:57:08 -0800
>>>>
>>>>> The driver is cxgb3 here, it uses LLTX.
>>>> That's extremely unfortunate, hopefully you can update it to
>>>> use a model like tg3 and others use.  LLTX is a lost cause
>>>> for hardware device drivers, and in fact we'd like to remove
>>>> it tree wide eventually.
> 
> Just for info: loopback.c uses it too :-)

Yes, we're all aware of this.  Google for "david miller loopback lltx" 
for a few examples...

Also, please do not strip CC's, that's quite annoying.

	Jeff



