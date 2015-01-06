From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] update ip-sysctl.txt documentation
Date: Tue, 6 Jan 2015 15:48:24 -0800
Message-ID: <20150106154824.6f2c9a75@urahara>
References: <1420574648-24213-1-git-send-email-ani@arista.com>
	<CAOxq_8OGx9VgSaEimAbNZSWjihNqNBXoVg0m8EPRaNX5jLXZiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:39557 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbAFXse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 18:48:34 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so878807pdb.4
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 15:48:34 -0800 (PST)
In-Reply-To: <CAOxq_8OGx9VgSaEimAbNZSWjihNqNBXoVg0m8EPRaNX5jLXZiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Jan 2015 14:02:29 -0800
Ani Sinha <ani@arista.com> wrote:

>  route/max_size - INTEGER
> -       Maximum number of routes allowed in the kernel.  Increase
> -       this when using large numbers of interfaces and/or routes.
> +        Post linux kernel 3.6, this is depricated for ipv4 as route cache is no
> +        longer used. For ipv6, this is used to limit the maximum number of ipv6
> +        routes allowed in the kernel.  Increase this when using large
> numbers of
> +        interfaces and/or routes.

1. You used mailer with line wrap which broke the patch.

2. The spelling is not correct 'depricated'
