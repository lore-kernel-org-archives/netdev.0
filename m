From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next v3 1/3] net: add ndo to get id of physical port
 of the device
Date: Mon, 22 Jul 2013 21:37:25 +0300
Message-ID: <CAJZOPZLHvgBzu2EuLw5ZWvrSFBsmESOVZQEgX91YH1PdfpsJbA@mail.gmail.com>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
	<1374498317-6442-2-git-send-email-jiri@resnulli.us>
	<CAJZOPZ+tbr8qvCJ7wDbXUhOEh4Q6j-_J1CFzFkb8nm4e3AwSrA@mail.gmail.com>
	<20130722180141.GA1498@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:33696 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932629Ab3GVSh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 14:37:26 -0400
Received: by mail-qa0-f52.google.com with SMTP id bq6so985944qab.4
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 11:37:26 -0700 (PDT)
In-Reply-To: <20130722180141.GA1498@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 9:01 PM, Jiri Pirko <jiri@resnulli.us> wrote:

> I have almost done implementation for igb/igbvf (consulting with Intel
> guys) and I'm working on bnx2x NPAR as well (consulting with Broadcom). I
> will post these patches soon.

good, I would prefer to have at least one driver patch as part of the
initial series, as typically done when adding e.g new ndo entry, makes
sense?

Or.
