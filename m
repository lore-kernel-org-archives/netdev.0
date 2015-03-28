From: Dave Taht <dave.taht@gmail.com>
Subject: reliably detecting IPV6_SUBTREEs support at runtime?
Date: Sat, 28 Mar 2015 08:48:24 -0700
Message-ID: <CAA93jw5h=xKcbghD3T4dts9W8Ouae2emaEj_8QFkXNe+v3JTLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34686 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbbC1PsY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 11:48:24 -0400
Received: by oigz129 with SMTP id z129so53154289oig.1
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2015 08:48:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anyone ideas for a test that a routing daemon could use at runtime
for detecting if IPV6_SUBTREES in the kernel is A) enabled and B)
working properly (as in post 3.11)?

--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
