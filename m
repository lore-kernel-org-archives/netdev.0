From: Nathan Williams <nathan@traverse.com.au>
Subject: Re: RX/close vcc race with solos/atmtcp/usbatm/he
Date: Wed, 16 Jun 2010 10:33:22 +1000
Message-ID: <4C181BD2.3090704@traverse.com.au>
References: <1274872584.20576.13579.camel@macbook.infradead.org> <1275904970.17903.4658.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:7967 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757992Ab0FPAiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 20:38:18 -0400
In-Reply-To: <1275904970.17903.4658.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/06/2010 8:02 PM, David Woodhouse wrote:
> On Wed, 2010-05-26 at 12:16 +0100, David Woodhouse wrote:
>> I've had this crash reported to me...
>>
>> [18842.727906] EIP: [<e082f490>] br2684_push+0x19/0x234 [br2684]
>> SS:ESP 0068:dfb89d14 
> 
> Nathan, did you manage to get your customer to confirm that this fixes
> the problem? It'd be useful to get this into 2.6.35 and -stable.
> 

No, I still haven't heard back from the customer.  I'll keep sending email reminders.
