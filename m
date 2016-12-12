From: Jiri Benc <jbenc@redhat.com>
Subject: Re: fib_frontend: Add network specific broadcasts, when it takes a
 sense
Date: Mon, 12 Dec 2016 15:52:32 +0100
Message-ID: <20161212155232.7ab99e5d@griffin>
References: <CAD2oYtOS3YKFhhAfXSdJUjKyAx9JpfGz-JLNvGC_mYP7zRp+Rg@mail.gmail.com>
        <20161212153035.4a751ccc@griffin>
        <CAD2oYtPPsvHgitejXTMAYa8qVvkibdPruEUcv8hhhiCfgfOvvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tom Denham <tom@tigera.io>,
        Aaron Levy <aaron.levy@coreos.com>,
        Brad Ison <bison@coreos.com>
To: Brandon Philips <brandon.philips@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41768 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752940AbcLLOwg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 09:52:36 -0500
In-Reply-To: <CAD2oYtPPsvHgitejXTMAYa8qVvkibdPruEUcv8hhhiCfgfOvvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Dec 2016 09:44:54 -0500, Brandon Philips wrote:
> Regardless, it is hard to find an RFC that says "simply don't do this
> because _____". The closest I could find was RFC 922 after sending
> this which says:

https://tools.ietf.org/html/rfc1812#section-5.3.5 is probably what
you're looking for.

 Jiri
