From: Schmiedl Christian <Christian.Schmiedl@gemalto.com>
Subject: RE: [PATCH] net: qmi_wwan: fix Cinterion PLXX product ID
Date: Thu, 26 Sep 2013 16:02:13 +0200
Message-ID: <376FB829F3ECB542B825EAF4D8CA8A9701F9D6114530@CROEXCFWP03.gemalto.com>
References: <1380121356-28601-1-git-send-email-aleksander@lanedo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"bjorn@mork.no" <bjorn@mork.no>,
	"dcbw@redhat.com" <dcbw@redhat.com>,
	Schemmel Hans-Christoph <Hans-Christoph.Schemmel@gemalto.com>,
	Colberg Nicolaus <Nicolaus.Colberg@gemalto.com>
To: Aleksander Morgado <aleksander@lanedo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.gemalto.com ([193.56.114.206]:53319 "EHLO
	smtp3.gemalto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792Ab3IZOXr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 10:23:47 -0400
In-Reply-To: <1380121356-28601-1-git-send-email-aleksander@lanedo.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aleksander Morgado <aleksander@lanedo.com> writes:

> Cinterion PLXX LTE devices have a 0x0060 product ID, not 0x12d1.
>
> The blacklisting in the serial/option driver does actually use the
> correct PID, as per commit 8ff10bdb14a52e3f25d4ce09e0582a8684c1a6db
> ('USB: Blacklisted Cinterion's PLxx WWAN Interface').

Thanks for patching

Acked-by: Christian Schmiedl <christian.schmiedl@gemalto.com>

Chris



This message and any attachments are intended solely for the addressees and may contain confidential information. Any unauthorized use or disclosure, either whole or partial, is prohibited.
E-mails are susceptible to alteration. Our company shall not be liable for the message if altered, changed or falsified. If you are not the intended recipient of this message, please delete it and notify the sender.
Although all reasonable efforts have been made to keep this transmission free from viruses, the sender will not be liable for damages caused by a transmitted virus
