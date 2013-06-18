From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next v2 00/12] openvswitch: gre tunneling support.
Date: Tue, 18 Jun 2013 09:21:23 +0300
Message-ID: <CAJZOPZLOA+NYux1baY820BR_hnNMZL6vnZW2G6Y8n2krwjOHdg@mail.gmail.com>
References: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:53552 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab3FRGVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 02:21:24 -0400
Received: by mail-qe0-f51.google.com with SMTP id a11so2217823qen.38
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 23:21:23 -0700 (PDT)
In-Reply-To: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 18, 2013 at 3:49 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch series adds support for gre tunneling.
> First six patches extend kernel gre and ip_tunnel modules
> api so that there is more code sharing between gre modules
> and ovs. Rest of patches adds ovs tunneling infrastructre
> and gre protocol vport.
>
> V2 fixes two patches according to comments from Jesse.

Hi Pravin,

I don't know what is the exact volume of changes between v1/v2 in this
case, but generally,
it would be very helpful if you make sure to spare few words on the
actual changes between versions.
