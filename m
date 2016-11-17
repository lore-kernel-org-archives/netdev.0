From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Thu, 17 Nov 2016 16:59:49 +0100
Message-ID: <20161117165950.6a8ed0d0@griffin>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
        <1479098638-4921-5-git-send-email-pshelar@ovn.org>
        <20161115153934.363e176d@griffin>
        <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@ovn.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935460AbcKQRS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:18:58 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2016 10:17:01 +0000, David Laight wrote:
> Worse than arbitrary, it adds 4 bytes of pad on 64bit systems.

It does not, this is not a struct.

 Jiri
