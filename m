From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: Linux 2.6.35-rc6
Date: Sat, 24 Jul 2010 10:06:16 +0200
Message-ID: <4C4A9EF8.6030409@gmail.com>
References: <AANLkTinJe-oHpgQqnTPQyKUtmKhg2oUJmylkBPALuzGh@mail.gmail.com> <20100723112142.f698394e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michal Marek <mmarek@suse.cz>, Greg KH <greg@kroah.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53656 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008Ab0GXIGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 04:06:19 -0400
In-Reply-To: <20100723112142.f698394e.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2010 03:21 AM, Stephen Rothwell wrote:
> On Thu, 22 Jul 2010 12:26:13 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>>
>  I actually hope/think that this is going to be the last -rc. Things
>> have been pretty quiet, and while this -rc has more commits than -rc5
>> had, it's not by a large amount, nor does it look scary to me. So
>> there doesn't seem to be any point in dragging out the release any
>> more, unless we find something new that calls for it.
> 
> I have no idea how important this stuff is, but I still have the
> following in linux-next that are (in theory) destined for v2.6.35:

Hi, and probably this one as well (introduced in rc1):
http://lkml.org/lkml/2010/7/9/287

Tim Gardner
  i915: Use the correct mask to detect i830 aperture size.

-- 
js
