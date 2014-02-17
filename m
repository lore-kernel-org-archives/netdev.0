From: Kevin Bowling <kevin.bowling@kev009.com>
Subject: Re: netmap, VALE and netmap pipes
Date: Mon, 17 Feb 2014 13:33:36 -0700
Message-ID: <ldtrmj$5vq$1@ger.gmane.org>
References: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>	<ldtmun$dqj$1@ger.gmane.org> <20140217121440.21a96821@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: freebsd-net@freebsd.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50468 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310AbaBQUdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 15:33:49 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1WFUst-0006BO-4c
	for netdev@vger.kernel.org; Mon, 17 Feb 2014 21:33:47 +0100
Received: from tempe0.bbox.io ([24.249.180.233])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 21:33:47 +0100
Received: from kevin.bowling by tempe0.bbox.io with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 21:33:47 +0100
In-Reply-To: <20140217121440.21a96821@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/17/2014 1:14 PM, Stephen Hemminger wrote:
> On Mon, 17 Feb 2014 12:12:36 -0700
> Kevin Bowling <kevin.bowling@kev009.com> wrote:
>
>> On 2/17/2014 3:11 AM, Luigi Rizzo wrote:
>>> Hi,
>>> we have recently made a few extensions to netmap/VALE and put various
>>> pieces of code on public repositories, so i thought i'd share the
>>> pointers. All the code below runs with equal features and performance
>>> on FreeBSD and Linux, and we are trying to upstream it in the relevant
>>> projects if possible (as an example, QEMU recently added a netmap backend),
>>> at which point some of these clone repositories will become unnecessary.
>>
>> Just a thought, maybe this is a good time for The FreeBSD Foundation to
>> reach out to The Linux Foundation for lobbying netmap into their main
>> line kernel.  It would be nice if netmap becomes the de facto UNIX
>> standard for this type of programming (it is vendor neutral and broadly
>> applicable vs other solutions), and avoid not-invented-here APIs like
>> non-blocking I/O went through with all the UNIX flavors.
>>
>> Regards,
>> Kevin Bowling

Hi Stephen,

> You do not understand the role of Linux Foundation.
> Lobbying would only serve to annoy the developers.

I attempted to say that with tongue in cheek and am sorry if I offended 
anyone.

> Netmap was submitted and rejected for a number of issues.
> Read the netdev mailing list archives if you want to follow what
> is going on.

I am not familiar with the situation on the Linux side.  My hope is that 
the opportunity window is not lost if there is a possibility for one API 
on both platforms.

Regards,
Kevin Bowling
