From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 08/32] net: dsa: dsa.c: Refactor to increase
 symmetry
Date: Fri, 11 Mar 2016 15:54:52 -0800
Message-ID: <56E35ACC.2030306@gmail.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <1456677700-23027-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36535 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcCKX41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:56:27 -0500
Received: by mail-pa0-f54.google.com with SMTP id tt10so111269040pab.3
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:56:27 -0800 (PST)
In-Reply-To: <1456677700-23027-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/02/16 08:41, Andrew Lunn wrote:
> Create a dsa_switch_finish() which does the opposite of dsa_switch_setup().
> Create a dsa_finish_dst() which does the opposite of dsa_setup_dst().
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
