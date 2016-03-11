From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v2 03/32] dsa: Make setup and finish more symmetrical
Date: Fri, 11 Mar 2016 15:54:08 -0800
Message-ID: <56E35AA0.5030904@gmail.com>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <1456677700-23027-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36269 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcCKXzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:55:42 -0500
Received: by mail-pf0-f169.google.com with SMTP id u190so64532971pfb.3
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:55:41 -0800 (PST)
In-Reply-To: <1456677700-23027-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/02/16 08:41, Andrew Lunn wrote:
> Rename and reposition dsa_switch_destroy() to dsa_switch_finish_one()
> to make it clear it is the opposite of dsa_switch_setup_one().
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
