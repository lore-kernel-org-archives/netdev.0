From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: dp83867: Fix device tree entries
Date: Mon, 08 Jun 2015 13:34:13 -0700
Message-ID: <5575FC45.9020100@gmail.com>
References: <1433791855-8265-1-git-send-email-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:34982 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753325AbbFHUfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 16:35:20 -0400
Received: by qczw4 with SMTP id w4so55101138qcz.2
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 13:35:19 -0700 (PDT)
In-Reply-To: <1433791855-8265-1-git-send-email-dmurphy@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/15 12:30, Dan Murphy wrote:
> Fix the device tree entries to modify the '_' to '-'.
> Also changes the names of the internal delay properties
> from -int- to -internal- as the -int- appeared as a keyword.
> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
