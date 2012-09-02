From: Fubo Chen <fubo.chen@gmail.com>
Subject: Re: [PATCH] net: Avoid spinlock recursion
Date: Sun, 2 Sep 2012 06:55:44 +0000
Message-ID: <CAJAFBLA6vBgm=DfPM3Hq5wpBz7vHng8eZeAFXcfCDLJ27XaGyg@mail.gmail.com>
References: <CAJAFBLCPjjBCmO0vxUeqSKJEkDkuQGF9H9hFRxWgFH92Kpz=VA@mail.gmail.com>
	<1346418123.20739.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:37544 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab2IBGzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 02:55:45 -0400
Received: by vbbff1 with SMTP id ff1so4471975vbb.19
        for <netdev@vger.kernel.org>; Sat, 01 Sep 2012 23:55:44 -0700 (PDT)
In-Reply-To: <1346418123.20739.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 31, 2012 at 1:02 PM, Cong Wang <amwang@redhat.com> wrote:
> On Mon, 2012-08-27 at 14:52 +0000, Fubo Chen wrote:
>> Fixes a bug introduced by commit 6bdb7fe31046ac50b47e83c35cd6c6b6160a475d.
>
> I already sent a patch:
> http://patchwork.ozlabs.org/patch/179954/

Sorry, I had missed your patch. Thanks for reply.

Fubo.
