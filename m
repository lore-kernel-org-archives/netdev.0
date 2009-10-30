From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH net-next 0/5] RDS: minor updates for net-next
Date: Fri, 30 Oct 2009 14:23:13 -0700
Message-ID: <c0a09e5c0910301423k7726909frde1ae63e6ac9f009@mail.gmail.com>
References: <1256928893-17844-1-git-send-email-andy.grover@oracle.com>
	 <20091030.122326.73781593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: andy.grover@oracle.com, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:33381 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932907AbZJ3VXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 17:23:09 -0400
Received: by pwj9 with SMTP id 9so871444pwj.21
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2009 14:23:13 -0700 (PDT)
In-Reply-To: <20091030.122326.73781593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2009 at 12:23 PM, David Miller <davem@davemloft.net> wrote:
>> These patches fix some small issues with RDS, please review and
>> apply if ok.
> Adding new socket options is not appropriate for -rc* series
> submissions.
>
> The changes that fix races and panics are fine, the rest is not.
>
> Please respin your changes properly for net-2.6, and we can add the
> socket option and do the other stuff in net-next-2.6

I'm fine with it all going into net-next, actually. Even the fixes are
not for showstopper bugs, and RDS is not a widely-used protocol.

Thanks -- Regards -- Andy
