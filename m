From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 23/26] net: mvneta: add EEE support
Date: Thu, 07 Jan 2016 12:35:38 -0800
Message-ID: <568ECC1A.8080804@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zkj-00076u-9Y@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36517 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbcAGUgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 15:36:12 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so174547347pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 12:36:12 -0800 (PST)
In-Reply-To: <E1a5zkj-00076u-9Y@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:39, Russell King wrote:
> Add EEE support to mvneta.  This allows us to enable the low power idle
> support at MAC level if there is a PHY attached through phylink which
> supports LPI.  The appropriate ethtool support is provided to allow the
> feature to be controlled, including ethtool statistics for EEE wakeup
> errors.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
