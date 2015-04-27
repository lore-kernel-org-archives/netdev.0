From: Anders Larsen <al@alarsen.net>
Subject: Re: Linux device driver for USB WIFI needs integrating
Date: Mon, 27 Apr 2015 17:11:20 +0200
Message-ID: <1430147480.5462.2@alarsen-lx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: Marek Vasut <marex@denx.de>, Chris Ward <tjcw@cantab.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jesper.alarsen.net ([144.76.18.233]:46566 "EHLO
	mail.alarsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbbD0PUY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 11:20:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(misspelled the list address - sorry)

On 2015-04-27 16:23, Chris Ward wrote:
> With the patch actually applied, the WiFi adapter is recognised and  
> works,
> both on boot and if the adapter is plugged in later. So, all is well.

glad to hear that - and thanks for testing!

> What mainline kernel level will contain the patch ?

Marek (CC'ed) added the USB ID some 4 weeks ago, so it's scheduled for  
the upcoming 4.1

@Marek: can we get your commit 9374e7d2 added to the stable kernels,  
please?
(the full discussion with Chris is archived here:  
https://lkml.org/lkml/2015/4/24/156)

Cheers
Anders
