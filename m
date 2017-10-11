From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] Add other KSZ switch support so that patch check does
 not complain
Date: Wed, 11 Oct 2017 14:18:02 -0700
Message-ID: <b4acd408-0f36-2050-b8c4-9eb46e6da92f@gmail.com>
References: <1507322009-15142-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com, Andrew Lunn <andrew@lunn.ch>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:46910 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdJKVSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:18:06 -0400
In-Reply-To: <1507322009-15142-1-git-send-email-Tristram.Ha@microchip.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2017 01:33 PM, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Add other KSZ switch support so that patch check does not complain.

You are not doing this just so checkpatch.pl stops complaining, what you
are doing here is to properly document the possible models supported by
this binding document.

Please also use a proper subject for this patch:

dt-bindings: dsa: Document additional Micrel KSZ family switches

or something along those lines.

With that:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
