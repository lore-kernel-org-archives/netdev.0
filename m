From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large divisor for flow classifier
Date: Fri, 15 Oct 2010 23:45:15 +0200
Message-ID: <4CB8CB6B.7080503@gmail.com>
References: <4CB899F7.0@navigue.com> <1287172905.2799.8.camel@edumazet-laptop> <4CB8C341.40000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jonathan Thibault <jonathan@navigue.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37076 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab0JOVpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 17:45:21 -0400
Received: by wyb28 with SMTP id 28so1094100wyb.19
        for <netdev@vger.kernel.org>; Fri, 15 Oct 2010 14:45:19 -0700 (PDT)
In-Reply-To: <4CB8C341.40000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Because of low SFQ_DEPTH, which limits its queue to 127 packets,
> SFQ isn't suitable for serving so many users. There is sch_drr as
> a replacement, alas more complex and undocumented [...]

Sorry! Actually there is a man page already!

Kudos to Florian!
Jarek P.
