From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/6] qlcnic: Add ethtool statistics for board
 temperature.
Date: Wed, 31 Jul 2013 10:47:58 -0700
Message-ID: <20130731104758.20dc03b1@nehalam.linuxnetplumber.net>
References: <cover.1375244889.git.himanshu.madhani@qlogic.com>
	<6a88678cfe46e0e4f639e8f80834dd3e4b46fdd1.1375244889.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:59360 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760687Ab3GaRsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 13:48:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so941544pdi.36
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 10:48:02 -0700 (PDT)
In-Reply-To: <6a88678cfe46e0e4f639e8f80834dd3e4b46fdd1.1375244889.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Jul 2013 21:54:19 -0400
Himanshu Madhani <himanshu.madhani@qlogic.com> wrote:

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o Added ethtool statistics to display adapter board
>   temperature.
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

If you look at igb driver you will see how Intel implemented temperature
monitoring to make it available through standard sensors.
