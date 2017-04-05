From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: broadcom: Add support for the BCM54210E
Date: Tue, 4 Apr 2017 22:47:42 -0700
Message-ID: <0d440b2f-5867-e413-ae25-2eea3adb1f9f@gmail.com>
References: <20170405053304.30246-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Jon Mason <jon.mason@broadcom.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joel Stanley <joel@jms.id.au>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36844 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdDEFrp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 01:47:45 -0400
In-Reply-To: <20170405053304.30246-1-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/04/2017 10:33 PM, Joel Stanley wrote:
> This device is a single-port RGMII 10/100/1000BASE-T PHY with EEE & WOL.

This looks good, although Rafal did beat you to it:

0fc9ae107669760c2a8658cb5b5876dbe525e08d ("net: phy: broadcom: add
support for BCM54210E")
-- 
Florian
