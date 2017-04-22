From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: compile issue in latest iproute2
Date: Sat, 22 Apr 2017 09:54:34 -0700
Message-ID: <20170422095434.730035b6@xeon-e3>
References: <cecf76aa-2883-741e-1901-2f4850e2c188@mojatatu.com>
        <58FB7012.4080907@iogearbox.net>
        <58FB8272.5080306@iogearbox.net>
        <b6773e0d-a8cb-181c-4aee-15d51439675f@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:36881 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425839AbdDVQyg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 12:54:36 -0400
Received: by mail-it0-f54.google.com with SMTP id x188so13143726itb.0
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 09:54:36 -0700 (PDT)
In-Reply-To: <b6773e0d-a8cb-181c-4aee-15d51439675f@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Apr 2017 12:43:50 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 17-04-22 12:18 PM, Daniel Borkmann wrote:
> [..]
> >
> > Anything I'm missing?  
> 
> 
> Let me get back to that machine (couple of hours) and try to see how i
> created the issue.
> Shouldve cutnpasted the error msg. Cant create it on this laptop.
> 
> cheers,
> jamal

Current tip of iproute2 master compiles fine for me
both with and without HAVE_ELF
