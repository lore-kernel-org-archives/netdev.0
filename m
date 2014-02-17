From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: netmap, VALE and netmap pipes
Date: Mon, 17 Feb 2014 12:14:40 -0800
Message-ID: <20140217121440.21a96821@nehalam.linuxnetplumber.net>
References: <CA+hQ2+gbs9aBneUaDGAnKVoPHspzc=5o+h+f_K=T+Cy8sRxr+w@mail.gmail.com>
	<ldtmun$dqj$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, freebsd-net@freebsd.org
To: Kevin Bowling <kevin.bowling@kev009.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:60374 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbaBQUOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:14:44 -0500
Received: by mail-pd0-f173.google.com with SMTP id y10so15237184pdj.18
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 12:14:43 -0800 (PST)
In-Reply-To: <ldtmun$dqj$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Feb 2014 12:12:36 -0700
Kevin Bowling <kevin.bowling@kev009.com> wrote:

> On 2/17/2014 3:11 AM, Luigi Rizzo wrote:
> > Hi,
> > we have recently made a few extensions to netmap/VALE and put various
> > pieces of code on public repositories, so i thought i'd share the
> > pointers. All the code below runs with equal features and performance
> > on FreeBSD and Linux, and we are trying to upstream it in the relevant
> > projects if possible (as an example, QEMU recently added a netmap backend),
> > at which point some of these clone repositories will become unnecessary.
> 
> Just a thought, maybe this is a good time for The FreeBSD Foundation to 
> reach out to The Linux Foundation for lobbying netmap into their main 
> line kernel.  It would be nice if netmap becomes the de facto UNIX 
> standard for this type of programming (it is vendor neutral and broadly 
> applicable vs other solutions), and avoid not-invented-here APIs like 
> non-blocking I/O went through with all the UNIX flavors.
> 
> Regards,
> Kevin Bowling

You do not understand the role of Linux Foundation.
Lobbying would only serve to annoy the developers.

Netmap was submitted and rejected for a number of issues.
Read the netdev mailing list archives if you want to follow what
is going on.
