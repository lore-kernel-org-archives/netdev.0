From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH 4/4] net: diag: Support destroying TCP sockets.
Date: Wed, 18 Nov 2015 13:46:16 +0900
Message-ID: <CAKD1Yr3p=jj_+VuDhhVnpJhxfR+jznkibgmjRSujtSwkHvc3jA@mail.gmail.com>
References: <1447811024-8553-5-git-send-email-lorenzo@google.com> <201511181134.PgceICPP%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:35365 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbbKREqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 23:46:36 -0500
Received: by ykba77 with SMTP id a77so45158765ykb.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 20:46:35 -0800 (PST)
In-Reply-To: <201511181134.PgceICPP%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 12:43 PM, kbuild test robot <lkp@intel.com> wrote:
> All errors (new ones prefixed by >>):
>
>>> ERROR: "inet_diag_find_one_icsk" [net/ipv4/tcp_diag.ko] undefined!

Oops. Missing export. Should be fixed in v2.
