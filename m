From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Mon, 02 Dec 2013 14:11:07 -0500
Message-ID: <529CDB4B.2040807@pobox.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com> <528A9A36.50903@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com> <20131119.161313.743887333007019981.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com> <20131120165420.GD9611@xanatos> <5299546B.2020800@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B744E@saturn3.aculab.com> <529CA1D2.2070806@pobox.com> <20131202190836.GC3898@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ming.lei@canonical.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:37273 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab3LBTLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 14:11:10 -0500
In-Reply-To: <20131202190836.GC3898@xanatos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-12-02 02:08 PM, Sarah Sharp wrote:
>> On 13-12-02 04:30 AM, David Laight wrote:
..
>>> Sarah needs to feed the xhci_ring.c fix through into stable.
..
> I'm working on it.  You will probably have to wait for -rc3, depending
> on when Greg sends his next pull request.  I will Cc you on the pull
> request and patch, which should be sent out today.

Super, exactly what we need, thanks!

-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
