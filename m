From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 09:43:47 -0400
Message-ID: <1243777427.3966.243.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	 <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <1243684218.3966.83.camel@dogo.mojatatu.com>
	 <20090531081213.GC2756@ami.dom.local>
	 <1243776293.3966.241.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:55288 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767AbZEaNoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 09:44:46 -0400
Received: by qyk36 with SMTP id 36so960962qyk.33
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 06:44:48 -0700 (PDT)
In-Reply-To: <1243776293.3966.241.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-05-31 at 09:24 -0400, jamal wrote:

> This would imply the classifier is buggy. I will stare at the different
> classifier - and if any exhibits such traits it needs to be fixed

I couldnt find any case where this is possible in the current code. If
you have a specific example, we need to fix it.

cheers,
jamal

