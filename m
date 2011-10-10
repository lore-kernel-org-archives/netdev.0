From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: SOMAXCONN = 128, but max defaults to 2048
Date: Mon, 10 Oct 2011 23:14:29 +0200
Message-ID: <20111010211429.GB8050@nuttenaction>
References: <CAGVGHmt1OVOj0NSEo3qHCh1CR10eZTNjxuUh_mB6sXxcx5gKmA@mail.gmail.com>
 <1318077339.5276.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf van der Spek <ml@vdspek.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:46644 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751272Ab1JJVOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 17:14:31 -0400
Content-Disposition: inline
In-Reply-To: <1318077339.5276.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-10-08 14:35:38 [+0200]:

>I routinely set net.core.somaxconn to 1024 on my servers.
>
>We had a recent discussion on the matter lately, but Hagen Paul Pfeifer
>did not polish his patches enough :
>
>http://lists.openwall.net/netdev/2011/03/20/3

Eric, I thought this change found no great acceptance ... ;-(

Hagen
