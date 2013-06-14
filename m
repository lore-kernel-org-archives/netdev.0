From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: mlx4_core 0000:05:00.0: event 19 arrived
Date: Fri, 14 Jun 2013 22:58:48 +0300
Message-ID: <CAJZOPZKAJMV6qY43zONh_82GcgW2NOrABHEqVzv4vp77Dy7xSQ@mail.gmail.com>
References: <20130614155342.GA7310@sbohrermbp13-local.rgmadvisors.com>
	<20130614161003.GB7310@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, amirv@mellanox.com
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:55565 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab3FNT6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 15:58:49 -0400
Received: by mail-qa0-f43.google.com with SMTP id d13so394697qak.9
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 12:58:49 -0700 (PDT)
In-Reply-To: <20130614161003.GB7310@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 7:10 PM, Shawn Bohrer <sbohrer@rgmadvisors.com> wrote:
> I also just remembered that I had set debug_level=1 on mlx4_core and
> that is likely why I am now seeing these messages.  If these messages
> are expected and harmless then I'll simply turn off the debug messages.

probably harmless, but let me check after the weekend and get back to
you. So you are using only mlx4_en, correct? no IPoIB nor user space
of your own that deal with QPs, SRQs (Shared Receive Queues) or alike
