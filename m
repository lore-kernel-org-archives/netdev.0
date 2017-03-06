From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: m_can: enable transmission of FD frame on latest
 version
Date: Mon, 6 Mar 2017 22:26:23 +0100
Message-ID: <fe3a4152-643c-404f-f236-5066089fba2e@hartkopp.net>
References: <20170306022143.7695-1-wenyou.yang@atmel.com>
 <e4360c52-d62d-6c35-f691-7fcd0f74f954@pengutronix.de>
 <b24f3252-6bd9-db48-b224-5bf3683cb75d@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        Wenyou Yang <wenyou.yang@microchip.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wenyou Yang <wenyou.yang@atmel.com>,
        Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.162]:33230 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753672AbdCFV3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 16:29:52 -0500
In-Reply-To: <b24f3252-6bd9-db48-b224-5bf3683cb75d@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

@Wenyou Yang: Can you please test the two patches posted here:

[PATCH 1/2] can: m_can: handle bitrate setup on IP core >= 3.1.x
http://marc.info/?l=linux-can&m=148883529927720&w=2

[PATCH 2/2] can: m_can: handle frame transmission on IP core >= 3.1.x
http://marc.info/?l=linux-can&m=148883529927718&w=2

Tnx & regards,
Oliver
