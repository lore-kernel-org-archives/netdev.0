From: Syed Muhammad Mohsin Kazmi <08beesmmkazmi@seecs.edu.pk>
Subject: data is truncated in skb
Date: Fri, 2 Mar 2012 06:13:55 +0500
Message-ID: <CAAZheX=A9=iuSDS+w4u_kqn4QvffdboKngopJgTegrsOUHQrHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34920 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069Ab2CBBN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 20:13:56 -0500
Received: by vbbff1 with SMTP id ff1so1067600vbb.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 17:13:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,
   I have written a code which encapsulates the packets GOINGOUT or
OTHERHOST in bridging module. Encapsulation is done fine. But data at
the end of buffer is truncated by the size of encapsulation. What
should i do to avoid truncation of data?
