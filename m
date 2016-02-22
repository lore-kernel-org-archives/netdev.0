From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net: ti: netcp: restore get/set_pad_info()
 functionality
Date: Sun, 21 Feb 2016 22:02:50 -0500 (EST)
Message-ID: <20160221.220250.1363843818216677470.davem@davemloft.net>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, arnd@arndb.de
To: m-karicheri2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Fri, 19 Feb 2016 12:58:41 -0500

> This series fixes a regression and add some improvements for the ease
> of maintainance. Incorporated comments against v1.
> 
> Changelogs:
>  
>  v2 : combined 2-3 into one patch as this involves a header change
>       fixed a parse warning in 3/4 per comment from Arnd.
>       Removed Sign-off from Arnd against 1/4
>       added comments in 3/3 to alert on the usage of sw data per review
>       comments
>  v1 : added 2-4 to accomodate feedback received from review
>  v0 : initial version to fix the regression (From Grygorii) 

Series applied, thanks.
