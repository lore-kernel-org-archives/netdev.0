From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Netfilter lacks ability to filter packets via Application-origin
Date: Fri, 28 Sep 2012 00:25:01 +0200
Message-ID: <CAFLxGvx+G05XyKZp-vLdF7OGJanG9ZQ06M5D4hjz5QfBBtSuhw@mail.gmail.com>
References: <COL002-W8067088C0C0B4682A10A0F39B0@phx.gbl>
	<COL002-W881A56C786C9972B7654E3F3830@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chad Gray <chad938@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58761 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab2I0WZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:25:02 -0400
Received: by bkcjk13 with SMTP id jk13so2622693bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 15:25:01 -0700 (PDT)
In-Reply-To: <COL002-W881A56C786C9972B7654E3F3830@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 27, 2012 at 11:04 PM, Chad Gray <chad938@hotmail.com> wrote:
> Users need the ability for Linux firewall to filter packets based on what
> Application they are originating from. This ability is present in Mac and
> Windows firewalls, but not Linux.
>
> For example, users would like ability to open Port 80 for Firefox, but keep
> Port 80 closed for other applications.

You can implement such filters using LSM like SELinux.

> This ability enhances Privacy & Security of the user but also helps to better
> inform the user about the comings and goings of internet traffic and what
> application/s are causing the traffic.

I seriously doubt that.

-- 
Thanks,
//richard
