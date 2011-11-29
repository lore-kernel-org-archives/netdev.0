From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 21:56:52 +0100
Message-ID: <1322600212.2596.13.camel@edumazet-laptop>
References: <4ED53AA1.9090800@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57744 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab1K2U47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 15:56:59 -0500
Received: by mail-ee0-f46.google.com with SMTP id u47so1322135eeu.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 12:56:58 -0800 (PST)
In-Reply-To: <4ED53AA1.9090800@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 12:03 -0800, Rick Jones a =C3=A9crit :

> Is the non-inheritance of the congestion control algorithm a bug or a=
=20
> feature?

IMHO its a bug.

Can you provide a fix ?

Thanks !
