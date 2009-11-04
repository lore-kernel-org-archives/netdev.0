From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cnic: ensure ulp_type is not negative
Date: Wed, 04 Nov 2009 05:07:16 -0800 (PST)
Message-ID: <20091104.050716.188290519.davem@davemloft.net>
References: <4AEF0E98.5050304@gmail.com>
	<1257184619.31958.3.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57187
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755992AbZKDNGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:06:52 -0500
In-Reply-To: <1257184619.31958.3.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 2 Nov 2009 09:56:59 -0800

> 
> On Mon, 2009-11-02 at 08:53 -0800, Roel Kluin wrote:
>> `ulp_type' is signed, make sure it is not negative
>> when we read the array element.
>> 
>> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Looks good to me.  Thanks.
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied to net-next-2.6
