From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Sun, 21 Jul 2013 14:14:33 +0300
Message-ID: <CAJZOPZKhRXfrjrMBm6FcXjFfnXzbvb6xz-UB8HoJYVSJ2Yix0Q@mail.gmail.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
	<20130711203938.GA4078@minipsycho.orion>
	<20130715153410.GA10864@fedora18-dev.oslab.blr.amer.dell.com>
	<CAJZOPZL7MVBphUvojJ7RjnF8EYVyMNgr4zta2_A8VZw7bKkRaQ@mail.gmail.com>
	<20130721072455.GA1944@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Narendra_K@dell.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:65262 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805Ab3GULOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 07:14:34 -0400
Received: by mail-qc0-f181.google.com with SMTP id u12so3091744qcx.26
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 04:14:33 -0700 (PDT)
In-Reply-To: <20130721072455.GA1944@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 21, 2013 at 10:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
[...]

Sorry, I missed that fact that initially you responded on this thread

> The value could be anything. But note that you have to have different
> values for card1-port1,2 and card2-port1,2

why?

Or.
