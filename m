From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Sat, 25 May 2013 09:02:38 -0500
Message-ID: <20130525140238.GA25744@lintop.rgmadvisors.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZKF6zoN3uZZQyYeHmGU4PZGOO1uvhe29WrdJ8qak_iMWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:65403 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226Ab3EYOCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 10:02:52 -0400
Received: by mail-ob0-f172.google.com with SMTP id tb18so6585537obb.17
        for <netdev@vger.kernel.org>; Sat, 25 May 2013 07:02:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZKF6zoN3uZZQyYeHmGU4PZGOO1uvhe29WrdJ8qak_iMWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 25, 2013 at 06:49:22AM +0300, Or Gerlitz wrote:
> On Fri, May 24, 2013 at 6:49 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> > I just started testing the 3.10 kernel, previously we were on 3.4 so
> > there is a fairly large jump.
> [...]
> 
> > 05:00.0 Network controller: Mellanox Technologies MT27500 Family
> > [ConnectX-3]
> >
> > # ethtool -i eth4
> > driver: mlx4_en
> > version: 2.0 (Dec 2011)
> > firmware-version: 2.11.500
> 
> Did you change firmware between the point it was working to where you are now?

Nope, we've been using 2.11.500 for a while now.

--
Shawn
