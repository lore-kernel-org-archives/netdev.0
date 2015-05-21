From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux
 v4.0-9362-g1fc149933fd4
Date: Thu, 21 May 2015 13:06:50 -0700
Message-ID: <1432238810.4060.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	 <20150504133943.GA17043@x131e>
	 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	 <20150504132714.55dca5b0@urahara>
	 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
	 <20150511131516.GC10375@x131e>
	 <1431355986.566.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150512182741.GD9693@x131e>
	 <CA+5PVA70p=y_62fkEG6OU=+-QpLX-SFi_mZ3UNgA4nu7GmvwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dominick Grift <dac.override@gmail.com>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37732 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712AbbEUUGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 16:06:52 -0400
Received: by igbsb11 with SMTP id sb11so17538098igb.0
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 13:06:51 -0700 (PDT)
In-Reply-To: <CA+5PVA70p=y_62fkEG6OU=+-QpLX-SFi_mZ3UNgA4nu7GmvwcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 15:22 -0400, Josh Boyer wrote:

> I'm still seeing this with Linus' tree as of yesterday.  Is this
> queued anywhere for 4.1?
I'll send the patch, thanks for the heads up.
