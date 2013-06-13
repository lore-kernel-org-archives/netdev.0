From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: Re: Davicom DM9000A regression
Date: Thu, 13 Jun 2013 09:22:48 +0300
Message-ID: <51B96538.9060107@compulab.co.il>
References: <51B87A19.4030708@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: josright123@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:32876 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476Ab3FMGWx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 02:22:53 -0400
In-Reply-To: <51B87A19.4030708@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 04:39 PM, Nikita Kiryanov wrote:
> Hi all.
>
> I've encountered a connectivity problem with Davicom DM9000A chip.
> The symptoms are the following message when booting via NFS:
> dm9000 dm9000.0: eth0: link up, 100Mbps, full-duplex, lpa 0xCDE1

Eh, copy pasted the wrong thing.
The message is a link down message:
dm9000 dm9000.0: eth0: link down

Also, CC-ing David Miller

-- 
Regards,
Nikita.
