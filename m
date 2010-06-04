From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH v2] ixgbevf: Enable GRO by default
Date: Thu, 3 Jun 2010 20:21:54 -0700
Message-ID: <AANLkTik2O9EMnoTJ8x1mapiwt0e3Gk4va5YR6nPBbqDj@mail.gmail.com>
References: <20100604031911.16828.76874.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shirley Ma <xma@us.ibm.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41786 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167Ab0FDDVz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:21:55 -0400
Received: by iwn37 with SMTP id 37so564195iwn.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 20:21:55 -0700 (PDT)
In-Reply-To: <20100604031911.16828.76874.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 3, 2010 at 20:19, Jeff Kirsher <jeffrey.t.kirsher@intel.com=
> wrote:
> From: Shirley Ma <mashirle@us.ibm.com>
>
> Enable GRO by default for performance.
>
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> Acked-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>
> =C2=A0drivers/net/ixgbevf/ixgbevf_main.c | =C2=A0 =C2=A01 +
> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>

Helps if I get Greg's email correct... :)
This second version has his *correct* email.
