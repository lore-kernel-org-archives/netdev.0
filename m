From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] connect() return value.
Date: Mon, 12 Aug 2002 00:46:51 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208112046.AAA16082@sex.inr.ac.ru>
References: <20020810102441.GA1126@anakin.wychk.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: glee@gnupilgrims.ORG (Geoffrey Lee)
In-Reply-To: <20020810102441.GA1126@anakin.wychk.org> from "Geoffrey Lee" at Aug 10, 2 03:15:01 pm
List-Id: netdev.vger.kernel.org

Hello!

> connect() doesn't return -EINTR on signal,

It does, when you ask not to restart after signal.


> The patch also addresses this.

It would be better if it did not. :-)

Alexey
