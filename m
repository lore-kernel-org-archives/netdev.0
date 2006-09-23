From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Restore the original TX FIFO overflow process.
Date: Fri, 22 Sep 2006 21:54:11 -0700
Message-ID: <20060922215411.85ac3f16.akpm@osdl.org>
References: <1158953401.2630.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31203 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750991AbWIWEyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:54:16 -0400
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1158953401.2630.0.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 15:30:01 -0400
Jesse Huang <jesse@icplus.com.tw> wrote:

>  #define DRV_NAME	"sundance"
> -#define DRV_VERSION	"1.01+LK1.14"
> -#define DRV_RELDATE	"04-Aug-2006"
> +#define DRV_VERSION	"1.01+LK1.15"
> +#define DRV_RELDATE	"22-Sep-2006"

Can we please delete this thing?  It's *forever* getting rejects and 
people only remember to update it a fraction of the time anyway.
