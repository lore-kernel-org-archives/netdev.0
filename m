From: Florian Fainelli <florian.fainelli@broadcom.com>
Subject: Re: [PATCH v5 2/7] Documentation: devicetree: add PHY lane swap
 binding
Date: Wed, 2 Nov 2016 10:11:38 -0700
Message-ID: <e5f926a8-ad35-f309-5ff7-8701f3c04121@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33085 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756380AbcKBRLl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 13:11:41 -0400
Received: by mail-pf0-f179.google.com with SMTP id d2so15179874pfd.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 10:11:41 -0700 (PDT)
In-Reply-To: <1478106488-11779-3-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2016 10:08 AM, Jon Mason wrote:
> Add the documentation for PHY lane swapping.  This is a boolean entry to
> notify the phy device drivers that the TX/RX lanes need to be swapped.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
