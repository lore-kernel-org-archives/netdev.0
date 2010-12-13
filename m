From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Using net_devices with ATM/DSL
Date: Sun, 12 Dec 2010 22:53:07 -0800
Message-ID: <4D05C2D3.7010306@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:41239 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751879Ab0LMHG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 02:06:59 -0500
Received: from macbook.redfish-solutions.com (71-34-110-194.ptld.qwest.net [71.34.110.194])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id oBD6r7Ml017385
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 23:53:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was trying to get this discussion rolling on linux-atm-general but didn't have much luck.

I was wondering what the downside to having ATM/DSL interfaces use net_devices would be?

Part of the reason for wanting to do this is to have an end-point to send/receive netlink messages to, so that the interface can report carrier state transitions, bit rates, bit-error rates, SNR, attenuation, constellations, transmitter gain, etc.

Seems simple enough.

Why not do this?

Thanks,

-Philip

