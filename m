From: Pawit Pornkitprasan <p.pawit@gmail.com>
Subject: Re: PROBLEM: Bridging does not work with Mellanox ConnectX-2
 (mlx4_en) card in SR-IOV mode
Date: Tue, 25 Jun 2013 09:46:19 +0900
Message-ID: <CAJA5wJSQiCbmNgv14yENe4PQtRxKeEC0KTcgVow4LnE-thyp2Q@mail.gmail.com>
References: <CAJA5wJQDRztwtMxJopUWfmqEOH39Xp0g-hCrY8gMZ2TKccSuhw@mail.gmail.com>
	<CAJZOPZLCG8_zfsP76EnEcGj3nUfP9batXMfvOqsPyNc63JqLSA@mail.gmail.com>
	<CAJA5wJRW1gai3pRXRD1fugrXQJxsJ3PDzVkLqWqjxvF-ixAheg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Ryousei Takano <takano-ryousei@aist.go.jp>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Amir Vadai <amirv@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:46355 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab3FYAqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 20:46:20 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar20so26522323iec.35
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 17:46:20 -0700 (PDT)
In-Reply-To: <CAJA5wJRW1gai3pRXRD1fugrXQJxsJ3PDzVkLqWqjxvF-ixAheg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 25, 2013 at 7:45 AM, Pawit Pornkitprasan <p.pawit@gmail.com> wrote:
>
> Thank you. I will try it out.
>

Update: I've tried "sudo bridge fdb add [target mac address] dev p4p1"
and the bridge is working properly. Is there any reason why the
bridging code cannot do this automatically?

Thank you,
Pawit
