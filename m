From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [iproute RFC PATCH 0/9] Document tc filters
Date: Fri, 23 Oct 2015 22:13:02 +0200
Message-ID: <20151023201302.GA2538@pox.localdomain>
References: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37591 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbbJWUNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 16:13:04 -0400
Received: by wicfv8 with SMTP id fv8so46493617wic.0
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 13:13:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445622436-6386-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/15 at 07:47pm, Phil Sutter wrote:
>  man/man8/Makefile     |   4 +-
>  man/man8/tc-basic.8   |  34 +++
>  man/man8/tc-cgroup.8  |  80 ++++++
>  man/man8/tc-flow.8    | 265 ++++++++++++++++++++
>  man/man8/tc-flower.8  | 113 +++++++++
>  man/man8/tc-fw.8      |  66 +++++
>  man/man8/tc-route.8   |  74 ++++++
>  man/man8/tc-tcindex.8 |  58 +++++
>  man/man8/tc-u32.8     | 663 ++++++++++++++++++++++++++++++++++++++++++++++++++

This basically says everything regarding the usability of u32 ;-)

Joke aside, thanks so much for doing this work. This is wonderful.
