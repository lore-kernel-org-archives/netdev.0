From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Sat, 25 May 2013 06:49:22 +0300
Message-ID: <CAJZOPZKF6zoN3uZZQyYeHmGU4PZGOO1uvhe29WrdJ8qak_iMWw@mail.gmail.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:35357 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280Ab3EYDtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 23:49:23 -0400
Received: by mail-qe0-f43.google.com with SMTP id k5so2932878qej.2
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 20:49:23 -0700 (PDT)
In-Reply-To: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 6:49 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> I just started testing the 3.10 kernel, previously we were on 3.4 so
> there is a fairly large jump.
[...]

> 05:00.0 Network controller: Mellanox Technologies MT27500 Family
> [ConnectX-3]
>
> # ethtool -i eth4
> driver: mlx4_en
> version: 2.0 (Dec 2011)
> firmware-version: 2.11.500

Did you change firmware between the point it was working to where you are now?
