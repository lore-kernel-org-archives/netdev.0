From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next 5/7] net: dsa: Rename DSA probe function.
Date: Wed, 13 Apr 2016 12:29:02 -0700
Message-ID: <570E9DFE.3020405@gmail.com>
References: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
 <1460508045-20254-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33866 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbcDMTbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 15:31:07 -0400
Received: by mail-pa0-f65.google.com with SMTP id hb4so4678608pac.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 12:31:06 -0700 (PDT)
In-Reply-To: <1460508045-20254-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/16 17:40, Andrew Lunn wrote:
> Rename the function called from the DSA to perform a probe for the
> switch. This makes the normal _probe() name available for a standard
> Linux device driver probe function.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
