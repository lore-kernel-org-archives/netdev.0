From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 04/13] rocker: push tlv processing into
 separate files
Date: Mon, 5 Oct 2015 21:47:57 -0700
Message-ID: <CAE4R7bBSinXckraFHEDrxZMo3-c-U6SQMK1KAvh50R_cRRwovw@mail.gmail.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us> <1444067046-27825-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33709 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbJFEsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 00:48:17 -0400
Received: by obbbh8 with SMTP id bh8so145422063obb.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 21:48:17 -0700 (PDT)
In-Reply-To: <1444067046-27825-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Carve out TLV processing helpers into separate files.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
