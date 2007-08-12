From: Vadim Dyadkin <dyadkin@lns.pnpi.spb.ru>
Subject: Re: troubles with r8169
Date: Mon, 13 Aug 2007 00:06:43 +0400
Message-ID: <46BF6853.4020800@lns.pnpi.spb.ru>
References: <fa.BZqd/vLw75Xm+ORj+HLjUzU1hSw@ifi.uio.no> <46BF61AB.5060400@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Hancock <hancockr@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dimail1.hmi.de ([134.30.95.50]:49739 "EHLO dimail1.hmi.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758213AbXHLUHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 16:07:22 -0400
In-Reply-To: <46BF61AB.5060400@shaw.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Hancock =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> This could well be a problem with the nvidia driver as it shares the
> same IRQ. The first step would be to see if the problem still shows u=
p
> without the nvidia binary module loaded.

Thank for your answer. This problem never shows up if I use only nvidia
driver (the work without network), or if I use only r8169 (without
x.org). If I use both of them I have the hang. Usually the hang appears
if OpenGL is used or network rate is maximal. I tested this regimes man=
y
times before.

Vadim
