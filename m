From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Mon, 7 Aug 2017 12:12:35 -0700
Message-ID: <20170807121235.4a8b5020@xeon-e3>
References: <8e8bc709-55b0-e207-b4bf-605bdf2ba323@gmail.com>
        <20170807110649.052e028a@xeon-e3>
        <bd0ad410-9b64-6f1b-6f78-08f6e801628b@gmail.com>
        <20170807.114517.1570408214504753399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, simon.horman@netronome.com,
        daniel@iogearbox.net, phil@nwl.cc, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36706 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751761AbdHGTMh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 15:12:37 -0400
Received: by mail-pg0-f44.google.com with SMTP id v77so5099655pgb.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 12:12:37 -0700 (PDT)
In-Reply-To: <20170807.114517.1570408214504753399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Aug 2017 11:45:17 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Ahern <dsahern@gmail.com>
> Date: Mon, 7 Aug 2017 12:09:31 -0600
> 
> > On 8/7/17 12:06 PM, Stephen Hemminger wrote:  
> >>> Does not work. Seems like you pushed the RFC commit which was known to
> >>> be incomplete.  
> >> 
> >> Patches welcome.  
> > 
> > What exists does not even compile. Patches will be sent once you fix that.  
> 
> Yeah seriously Stephen, you created this huge mess so the onus is really
> on you to fix it up.

It is fixed now.
Dave, I asked for test cases, and received none.
