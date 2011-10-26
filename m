From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [patch net-next V2] net: introduce ethernet teaming device
Date: Wed, 26 Oct 2011 16:31:50 +0200
Message-ID: <CAJZOPZK5vZEgAP3tmeMHamF6jfLpmmOtOu6g_gkY6QGmabL2VQ@mail.gmail.com>
References: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46378 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932772Ab1JZObv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 10:31:51 -0400
Received: by wwe6 with SMTP id 6so2535093wwe.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 07:31:50 -0700 (PDT)
In-Reply-To: <1319200747-2508-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [...] keep kernel code as slim and clean as possible and do what can be done in userspace
> in userspace. [...] Bonding is carring a lot of baggage, team does not. It's light and it suppose
> to stay that way.  Also I would add easy extensibility by writing new mode
> in case any existing is not suitable for your needs. I hope this clears it up for you.


Yes, this clears a lot, so it can be seen as major bonding design/face
lifting done through re-write, such that at the end of the day,
teaming could replace
bonding, makes sense?

Or.
