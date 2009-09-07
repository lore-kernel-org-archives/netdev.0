From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: Staging: cpc-usb CAN driver TODO list
Date: Mon, 07 Sep 2009 09:05:42 +0200
Message-ID: <4AA4B0C6.5080608@grandegger.com>
References: <4AA262CB.7060607@hartkopp.net> <4AA4A0A2.2070907@ems-wuensche.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>, Greg KH <greg@kroah.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Felipe Balbi <me@felipebalbi.com>
To: Sebastian Haas <haas@ems-wuensche.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:40142 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbZIGHFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 03:05:48 -0400
In-Reply-To: <4AA4A0A2.2070907@ems-wuensche.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastian,

On 09/07/2009 07:56 AM, Sebastian Haas wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Oliver,
>
> I'm not yet sure how to actually start the development. There is so much
> to do, and I've not much time to spend on this, unfortunately. Because
> of this I can't rewrite the whole driver on my own in order to get a
> Socket-CAN driver but I can provide support, review patches, rent
> devices and make tests here.
>
> Oliver, you are not familiar with USB and I'm not very familiar with CAN
> netdev internals, why not combining these twos. You are writing the CAN
> part and write the USB part.
>
> I'll also write a specification which contains any information you need
> to develop a CAN driver for the device (commands, sequences, error
> handling).

Alternatively, EMS Wuensche could also hire an expert doing the job ;-). 
Note that we do a lot of Socket-CAN work in our free time, which is a 
limited resource. Progress depends on funding to a certain extend.

Wolfgang.
