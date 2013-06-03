From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [Patch net-next 1/2] ping: some cleanup for net/ipv4/ping.c
Date: Mon, 3 Jun 2013 16:17:25 +0900
Message-ID: <CAKD1Yr2fn51+5JEUN2vg+NJ7yv_Fe-WqPhETFee5mv+_FJDaMA@mail.gmail.com>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com>
 <CAKD1Yr0zHsM85ZJLwCeE6NkEZnaMqs3ba1PyOa_M09UB6i99=g@mail.gmail.com> <1370243586.32297.5.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:56589 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab3FCHRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:17:47 -0400
Received: by mail-qc0-f175.google.com with SMTP id a1so1941503qcx.6
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 00:17:46 -0700 (PDT)
In-Reply-To: <1370243586.32297.5.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 3, 2013 at 4:13 PM, Cong Wang <amwang@redhat.com> wrote:
> Remember it is a cleanup, not a bug fix, right? :) I don't think there
> is any way to make this 10- line of code hard to read.

I suppose, if growing the function from 2 to 9 lines without changing
its behaviour can be called a "cleanup". :-)
