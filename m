From: Grant Grundler <grundler@google.com>
Subject: smsc75xx maintainer?
Date: Wed, 15 Aug 2012 14:48:35 -0700
Message-ID: <CANEJEGuh++1-7HajcK65a=NPyKY_5JWkjGQFOKddv4JrVn0gFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:37589 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab2HOVsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2012 17:48:36 -0400
Received: by obbuo13 with SMTP id uo13so2669732obb.19
        for <netdev@vger.kernel.org>; Wed, 15 Aug 2012 14:48:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

scripts/get_maintainer.pl can't identify an owner for
drivers/net/usb/smsc75xx.c (USB GigE dongle).

Anyone (at SMSC?) interested in fixing suspend/resume for smsc75xx driver?

I don't have time to chase this but it would be nice if this part
worked. Only suspend/resume appears broken.

Some details in http://crosbug.com/31871.

thanks,
grant
