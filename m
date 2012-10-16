From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net] vlan: fix bond/team enslave of vlan challenged
 slave/port
Date: Tue, 16 Oct 2012 14:59:35 +0200
Message-ID: <20121016125935.GA1614@minipsycho.brq.redhat.com>
References: <1350225056-14144-1-git-send-email-jiri@resnulli.us>
 <CAJtaB1ugcEp13LYX6yJL0DX4EVX53h7MyumzRGDLZ_u8fyu_WA@mail.gmail.com>
 <CAJtaB1vRoArmDe_FB_dF-oQUcSsHPbTQ31wzPJLPtLKsq0k53Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net
To: Jon Stanley <jstanley@rmrf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45600 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725Ab2JPM7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 08:59:41 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2981407bkc.19
        for <netdev@vger.kernel.org>; Tue, 16 Oct 2012 05:59:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJtaB1vRoArmDe_FB_dF-oQUcSsHPbTQ31wzPJLPtLKsq0k53Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 15, 2012 at 10:38:44PM CEST, jstanley@rmrf.net wrote:
>On Mon, Oct 15, 2012 at 10:53 AM, Jon Stanley <jstanley@rmrf.net> wrote:
>
>> However, I'm now running into a new issue. Note that I've backported
>> this to an older kernel (3.3.2, eww)
>
>My bad, I tried this on mainline and it works fine. Any pointers on
>what needs to get backported into 3.3 before I go pulling my hair out
>over it? :)

I can't think about anything atm. Happy hair pulling :)

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
