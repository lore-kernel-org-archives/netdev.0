From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] tc: m_tunnel_key: add csum/nocsum option
Date: Fri, 16 Jun 2017 09:12:22 -0700
Message-ID: <20170616091222.4119bdf8@xeon-e3>
References: <cover.1497467840.git.jbenc@redhat.com>
        <20170614213018.364cd85d@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36042 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdFPQMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:12:30 -0400
Received: by mail-pf0-f174.google.com with SMTP id x63so24379534pff.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 09:12:29 -0700 (PDT)
In-Reply-To: <20170614213018.364cd85d@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jun 2017 21:30:18 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> Allows control of UDP zero checksum.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied both patches to net-next
