From: Jon Stanley <jstanley@rmrf.net>
Subject: Re: [patch net] vlan: fix bond/team enslave of vlan challenged slave/port
Date: Mon, 15 Oct 2012 16:38:44 -0400
Message-ID: <CAJtaB1vRoArmDe_FB_dF-oQUcSsHPbTQ31wzPJLPtLKsq0k53Q@mail.gmail.com>
References: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
	<CAJtaB1ugcEp13LYX6yJL0DX4EVX53h7MyumzRGDLZ_u8fyu_WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:63387 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab2JOUip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 16:38:45 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so436399qcr.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 13:38:44 -0700 (PDT)
In-Reply-To: <CAJtaB1ugcEp13LYX6yJL0DX4EVX53h7MyumzRGDLZ_u8fyu_WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 15, 2012 at 10:53 AM, Jon Stanley <jstanley@rmrf.net> wrote:

> However, I'm now running into a new issue. Note that I've backported
> this to an older kernel (3.3.2, eww)

My bad, I tried this on mainline and it works fine. Any pointers on
what needs to get backported into 3.3 before I go pulling my hair out
over it? :)
