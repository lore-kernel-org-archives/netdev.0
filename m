From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: KS8851: Performance Improvement
Date: Tue, 2 Feb 2010 20:25:12 -0600
Message-ID: <cb8016981002021825i5d1ad8b0o35db3c86e046aa83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35491 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756312Ab0BCCZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 21:25:13 -0500
Received: by vws20 with SMTP id 20so258234vws.19
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2010 18:25:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am working with ks8851 snl ethernet controller attached to a OMAP4
board and did a nuttcp benchmark, the result is

12.9375 MB /  10.49 sec =   10.3491 Mbps 1 %TX 0 %RX

According to a previous post from Ha, Tristram he did get ~11 Mbps
with a Beagle Zippy combo board.

Are there any pending changes at the driver level so performance can
be increased ~100 Mbps? do we have any hardware limitation? any extra
SPI specifications?

Thanks for your comments...

Best Regards
Abraham
