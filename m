From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: stack smashing in iproute/ip
Date: Wed, 27 May 2015 18:31:41 -0700
Message-ID: <20150527183141.0ff9caa9@urahara>
References: <555AF73C.7050405@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jetchko Jekov <jetchko.jekov@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32818 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbbE1Bbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 21:31:39 -0400
Received: by padbw4 with SMTP id bw4so10890250pad.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 18:31:38 -0700 (PDT)
In-Reply-To: <555AF73C.7050405@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 May 2015 10:41:32 +0200
Jetchko Jekov <jetchko.jekov@nokia.com> wrote:

> Hello,
> 
> I hope this is the right way to report a bug regarding iproute.
> 
> While playing with gre[tap] tunnels I run in the following:

I integrated your patch into upcoming release.
