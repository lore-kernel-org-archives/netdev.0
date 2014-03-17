From: Oliver Neukum <oneukum@suse.de>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Mon, 17 Mar 2014 22:55:43 +0100
Message-ID: <1395093343.3961.2.camel@linux-fkkt.site>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	 <CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	 <CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	 <1394529263.16128.6.camel@linux-fkkt.site>
	 <CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	 <CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@google.com>,
	netdev <netdev@vger.kernel.org>, Freddy Xin <freddy@asix.com.tw>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Allan Chou <allan@asix.com.tw>
To: Julius Werner <jwerner@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49478 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbaCQVzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 17:55:45 -0400
In-Reply-To: <CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 14:53 -0700, Julius Werner wrote:
> Hi Oliver,
> 
> Any update on the state of this patch? Did it get picked up for merge
> somewhere? Do you agree with my suggestion of sticking closer to the
> original logic instead of adding that autopm_get(), or do you maybe
> want to add some more reviewers to confirm your code? I don't really
> care that much which way we choose in the end, I just want to make
> sure this bug gets fixed and we don't forget about it.

I am hping for the reporter of the original bug to test it.

	Regards
		Oliver
