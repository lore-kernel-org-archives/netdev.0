From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [iproute PATCH v2 2/2] ss: support closing inet sockets via SOCK_DESTROY.
Date: Tue, 22 Dec 2015 17:35:33 +0900
Message-ID: <CAKD1Yr3csvK=bDYt2v_GSXYX-_kDmDY4AZe2WkjE6qa424o9Og@mail.gmail.com>
References: <20151221214222.5ee87383@xeon-e3> <1450773094-7978-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33207 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbbLVIfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 03:35:54 -0500
Received: by mail-yk0-f172.google.com with SMTP id 140so156826143ykp.0
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 00:35:53 -0800 (PST)
In-Reply-To: <1450773094-7978-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 5:31 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> I've just uploaded a new version. The changes from v2 are as
> follows:
> [...]

Also: as requested, kill is now a boolean instead of a bitfield inside a struct.
