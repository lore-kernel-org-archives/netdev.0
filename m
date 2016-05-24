From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 PATCH v2 1/1] tc simple action update and breakage
Date: Mon, 23 May 2016 20:59:23 -0400
Message-ID: <5743A76B.2010803@mojatatu.com>
References: <1462719726-7598-1-git-send-email-jhs@emojatatu.com>
 <57438697.8030801@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:36018 "EHLO
	mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbcEXA70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 20:59:26 -0400
Received: by mail-it0-f45.google.com with SMTP id e62so41944485ita.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 17:59:26 -0700 (PDT)
In-Reply-To: <57438697.8030801@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-23 06:39 PM, Daniel Borkmann wrote:

>
> m_simple.c: In function =91parse_simple=92:
> m_simple.c:154:6: warning: too many arguments for format
> [-Wformat-extra-args]
>        *argv);
>        ^
> m_simple.c:103:14: warning: unused variable =91maybe_bind=92
> [-Wunused-variable]
>    int ok =3D 0, maybe_bind =3D 0;
>                ^

Will send a fix. Thanks Daniel.

cheers,
jamal
