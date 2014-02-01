From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Sat, 01 Feb 2014 15:05:21 -0500
Message-ID: <52ED5381.2010106@pobox.com>
References: <20140130211816.GB3787@xanatos>	<87iot1qgv6.fsf@nemi.mork.no>	<20140130221511.GD14228@xanatos>	<CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>	<20140131190035.GB18262@xanatos>	<CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>	<52ECF6F5.6060207@pobox.com> <CACVXFVOynsojKo+aukHY4q+MkEyhHXC0=OpN0ysu0TGuUjY8sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	=?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	David Laight <David.Laight@aculab.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:54680 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074AbaBAUFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 15:05:32 -0500
In-Reply-To: <CACVXFVOynsojKo+aukHY4q+MkEyhHXC0=OpN0ysu0TGuUjY8sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-02-01 09:18 AM, Ming Lei wrote:
>
> Even real regressions are easily/often introduced, and we are discussing
> how to fix that. I suggest to unset the flag only for the known buggy
> controllers.


It is not the controllers that are particularly "buggy" here.
But rather the drivers and design of parts of the kernel.

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
