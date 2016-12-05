From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net-next 3/3] net: ethoc: Demote packet dropped error
 message to debug
Date: Mon, 5 Dec 2016 08:21:33 +0100
Message-ID: <20161205072133.GD22467@distanz.ch>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
 <20161204204030.9853-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:57431 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751627AbcLEHVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 02:21:42 -0500
Content-Disposition: inline
In-Reply-To: <20161204204030.9853-4-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-04 at 21:40:30 +0100, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Spamming the console with: net eth1: packet dropped can happen
> fairly frequently if the adapter is busy transmitting, demote the
> message to a debug print.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
