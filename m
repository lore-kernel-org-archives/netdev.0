From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux
 v4.0-9362-g1fc149933fd4
Date: Mon, 11 May 2015 17:37:37 -0700
Message-ID: <1431391057.566.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	 <20150504133943.GA17043@x131e>
	 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	 <20150504132714.55dca5b0@urahara>
	 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
	 <20150511131516.GC10375@x131e>
	 <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555145A8.8010003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dominick Grift <dac.override@gmail.com>, netdev@vger.kernel.org
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36415 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbbELAhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 20:37:40 -0400
Received: by igbpi8 with SMTP id pi8so87051598igb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 17:37:39 -0700 (PDT)
In-Reply-To: <555145A8.8010003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 02:13 +0200, poma wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=98081#c2

Reported panic has nothing to do with this RCU issue.

I would say your test is non conclusive.
