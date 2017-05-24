From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] drivers: phy: Add Cortina CS4340 driver
Date: Wed, 24 May 2017 10:02:41 -0700
Message-ID: <1c7a1799-7b76-6e1d-5050-b4abb7855a94@gmail.com>
References: <1495617948-13435-1-git-send-email-bogdan.purcareata@nxp.com>
 <20170524125830.GB24341@lunn.ch>
 <DB5PR04MB1240541B2CFB2C99ED519CDFEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
 <20170524142543.GD26577@lunn.ch>
 <DB5PR04MB124053B977F50D4A68C99D7BEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bogdan Purcareata <bogdan.purcareata@nxp.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34087 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755092AbdEXRCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 13:02:45 -0400
In-Reply-To: <DB5PR04MB124053B977F50D4A68C99D7BEAFE0@DB5PR04MB1240.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 07:34 AM, Bogdan Purcareata wrote:
>> You should do that as well.
> 
> Okay, I will include this check in a probe function in v3.

When you do so, can you change the subject to be net: phy: Add Cortina
CS4340 driver for the driver, and use dt-bindings: net:  for the Device
Tree binding patch?

Thanks!
-- 
Florian
