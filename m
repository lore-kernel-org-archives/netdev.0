From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] isdn: remove deprecated ISDN_CAPI_CAPIFS
Date: Thu, 07 Apr 2011 15:06:49 +0800
Message-ID: <4D9D6289.8000805@redhat.com>
References: <1302080739-4029-1-git-send-email-amwang@redhat.com> <20110406.131216.15250040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de, jan.kiszka@web.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573Ab1DGHHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 03:07:00 -0400
In-Reply-To: <20110406.131216.15250040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B404=E6=9C=8807=E6=97=A5 04:12, David Miller =E5=86=
=99=E9=81=93:
> From: Amerigo Wang<amwang@redhat.com>
> Date: Wed,  6 Apr 2011 17:05:39 +0800
>
>> Cc: Jan Kiszka<jan.kiszka@web.de>
>> Cc: Karsten Keil<isdn@linux-pingi.de>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>
> capi.c still includes capifs.h, which you are deleting here.
>
> How did you build test this?

Oops! I definitely used a wrong .config.. :-/

Thanks for fixing it, Jan!
