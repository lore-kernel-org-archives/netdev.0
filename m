From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v7 02/10] ss: created formatters for json and hr
Date: Thu, 24 Sep 2015 15:16:30 -0700
Message-ID: <20150924151630.28129cdb@urahara>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
	<1441913708-15532-3-git-send-email-matthias.tafelmeier@gmx.net>
	<20150923162650.148fe95b@urahara>
	<bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34015 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbbIXWQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 18:16:21 -0400
Received: by padhy16 with SMTP id hy16so84836769pad.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 15:16:20 -0700 (PDT)
In-Reply-To: <bc9cacb94de24857a7d9e13960bfae56@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2015 17:43:46 +0000
Matthias Tafelmeier <matthias.tafelmeier@gmx.net> wrote:

> > Maybe it is time to rewrite it in a better language ;-)  
> 
> I did not get that. Do you mean iproute2?

I meant that the amount of formatting and string processing in ss is
getting to be a significant fraction of the code. Languages other C
provide more OO and better string handling that might help.
But mostly it was a joke.
