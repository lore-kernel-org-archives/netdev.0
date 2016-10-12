From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Wed, 12 Oct 2016 08:52:15 +0200
Message-ID: <1476255135.1972.5.camel@tiscali.nl>
References: <20161010071943.4717-1-chris@rorvick.com>
         <1476108164.5210.11.camel@coelho.fi> <1476180668.17022.21.camel@tiscali.nl>
         <1476252719.7776.6.camel@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Luca Coelho <luca@coelho.fi>, Chris Rorvick <chris@rorvick.com>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud2.xs4all.net ([194.109.24.25]:52024 "EHLO
        lb2-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753878AbcJLGwX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 02:52:23 -0400
In-Reply-To: <1476252719.7776.6.camel@coelho.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luca,

On Wed, 2016-10-12 at 09:11 +0300, Luca Coelho wrote:
> By "platform" I meant the PC you are using.  The ACPI table is created
> by the OEM, so different PCs have different tables.

Like Chris I use a Dell XPS 13 (9350), but mine came with an AC 8260
out of it's assembly plant:
    Detected Intel(R) Dual Band Wireless AC 8260, REV=0x208

> In any case, I will rework this code, so I'd prefer if we skip this
> patch entirely.

Feel free to prod me for testing whatever you come up with.


Paul Bolle
