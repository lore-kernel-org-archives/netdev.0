From: Fabio Estevam <festevam@gmail.com>
Subject: Regulator support for smsc911x
Date: Thu, 2 Feb 2012 23:02:49 -0200
Message-ID: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: robert.marklund@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:35364 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104Ab2BCBCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 20:02:49 -0500
Received: by dadp15 with SMTP id p15so2318046dad.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 17:02:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert,

Since commit c7e963f6 (net/smsc911x: Add regulator support) I am no
longer able to use smsc911x driver due to the lack of regulators for
smsc on mx31_3ds board.

Do you a board example that uses such regulator, so that I can look
for a reference?

Regards,

Fabio Estevam
