From: Rob Townley <rob.townley@gmail.com>
Subject: Re: [PATCH] iputils: ping by mark
Date: Fri, 16 Oct 2009 16:05:39 -0500
Message-ID: <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
References: <1255381558.5406.33.camel@dogo.mojatatu.com>
Reply-To: Rob.Townley@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f184.google.com ([209.85.212.184]:61090 "EHLO
	mail-vw0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065AbZJPVM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 17:12:29 -0400
Received: by vws14 with SMTP id 14so553926vws.33
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 14:12:34 -0700 (PDT)
In-Reply-To: <1255381558.5406.33.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2009 at 4:05 PM, jamal <hadi@cyberus.ca> wrote:
>
> ping by mark, example to use firewall mark decimal 10
> (which hopefully maps to something meaningful with policy routing):
>
> ping -m 10 10.0.0.1
>
> cheers,
> jamal
>

Would this make it easier to ping multiple gateways so if one goes
down, it is taken almost out of the routing table until it comes back
up.
