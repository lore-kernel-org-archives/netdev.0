From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V1 1/8] net/mlx4: Address build warnings on set
 but not used variables
Date: Tue, 15 May 2012 22:49:40 +0300
Message-ID: <CAJZOPZ+doj09gns9yu-VTGpriuGfrEjBJviJs8Ci7M_GzHndiw@mail.gmail.com>
References: <1337066690-2248-1-git-send-email-ogerlitz@mellanox.com>
	<1337066690-2248-2-git-send-email-ogerlitz@mellanox.com>
	<20120515.133808.1788429614608005541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roland@kernel.org, netdev@vger.kernel.org, yevgenyp@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:59311 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965990Ab2EOTtl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2012 15:49:41 -0400
Received: by lahd3 with SMTP id d3so4436670lah.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 12:49:40 -0700 (PDT)
In-Reply-To: <20120515.133808.1788429614608005541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 15, 2012 at 8:38 PM, David Miller <davem@davemloft.net> wro=
te:
> Instead you use TAB and SPACE characters, as needed, to line it up
> properly, like so:
>
> =A0 =A0 =A0 =A0func(arg1, arg2,
> =A0 =A0 =A0 =A0 =A0 =A0 arg3, arg4);

Got it, thanks, will send V2 with this fixed

Or.
