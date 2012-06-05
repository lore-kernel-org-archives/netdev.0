From: Jim Cromie <jim.cromie@gmail.com>
Subject: Re: [PATCH net-next 0/3] Remove casts to same type
Date: Mon, 4 Jun 2012 22:48:21 -0600
Message-ID: <CAJfuBxzVLzQK_d=JqJVzQnzHWZDtAJMihkEXWh7xeimMq9FHxQ@mail.gmail.com>
References: <cover.1338849364.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42355 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627Ab2FEEsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 00:48:52 -0400
Received: by gglu4 with SMTP id u4so3667201ggl.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 21:48:51 -0700 (PDT)
In-Reply-To: <cover.1338849364.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 4, 2012 at 4:44 PM, Joe Perches <joe@perches.com> wrote:
> Adding casts of objects to the same type is unnecessary
> and confusing for a human reader.
>
> Remove them via coccinelle script.
>

Can you also post the coccinelle script ?

did you have to edit them any futher, or is it 100% script ?
