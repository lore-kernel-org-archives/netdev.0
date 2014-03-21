From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: Re: openvswitch question
Date: Fri, 21 Mar 2014 20:45:02 +0530
Message-ID: <CAGZFCEFZgjStq7kH2pfi+X-sjJU69v7zXWey6JztWH1Y-XoXYQ@mail.gmail.com>
References: <CAGZFCEHSVpH8XN4n3A3xhVtYNqp4kn3PM7aXWRCxKFSkQVfABQ@mail.gmail.com>
	<CAEP_g=8=BxsXe7PNPAvyEVCDFLCRrskEPVf1ts6Aoo4-eRtQug@mail.gmail.com>
	<532C0B76.4020108@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:45460 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759957AbaCUPPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 11:15:03 -0400
Received: by mail-yk0-f170.google.com with SMTP id 9so6542147ykp.1
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 08:15:02 -0700 (PDT)
In-Reply-To: <532C0B76.4020108@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2014 at 3:20 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Stop me if I'm wrong, but there may be a difference with netns, the
> netdevice
> can be in a different netns than the ovs port.

No.  below command show  no name space.

ip netns list

-Ratheesh
