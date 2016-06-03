From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 10/17] net: dsa: mv88e6xxx: Only support EDSA
 tagging
Date: Fri, 3 Jun 2016 14:20:44 -0700
Message-ID: <5751F4AC.102@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-11-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32967 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340AbcFCVUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:20:47 -0400
Received: by mail-pa0-f44.google.com with SMTP id ec8so11751600pac.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:20:46 -0700 (PDT)
In-Reply-To: <1464972256-10408-11-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> The merged driver no longer offers the option to use DSA tagging. So
> remove the code to setup the switch to do DSA tagging and hard code
> the use of EDSA.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
