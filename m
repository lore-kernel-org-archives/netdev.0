From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute/master 0/3] lost mpls ip tunnel patches
Date: Wed, 14 Jun 2017 10:24:51 -0700
Message-ID: <20170614102451.42b301bd@xeon-e3>
References: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
        dsahern@gmail.com
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36793 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdFNRY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 13:24:59 -0400
Received: by mail-pf0-f179.google.com with SMTP id x63so3395909pff.3
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 10:24:58 -0700 (PDT)
In-Reply-To: <1497058292-10099-1-git-send-email-kjlx@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  9 Jun 2017 18:31:29 -0700
Krister Johansen <kjlx@templeofstupid.com> wrote:

> Hi Stephen,
> I'm a bit unsure of the decorum in this particular situation. Kernel
> support for mpls/ip tunnels was integrated back in July of 2016.  At the
> time, the author of that feature sent out a RFC patch for the iproute
> support but never followed up on subsequent code review comments.
> 
> The kernel support got merged, but the iproute support never made it in.
> I wanted to run some tests with these features.  In the process, I
> tracked down the author's original patches, merged them into current
> iproute, and attempted to address the comments from code reviewers.
>

In order to get merged, an RFC message should be followed by a final
non RFC version. I think you will find the original's were marked
in patchwork as RFC.
