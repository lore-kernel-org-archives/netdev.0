From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 03/03] [PATCH] vxlan: fix crash on module removal
Date: Mon, 10 Jun 2013 14:48:14 -0700
Message-ID: <20130610144814.44aca116@nehalam.linuxnetplumber.net>
References: <20130610131315.384c5b61@nehalam.linuxnetplumber.net>
	<20130610.140114.1116004856133608655.davem@redhat.com>
	<20130610.141421.1570141372448161465.davem@davemloft.net>
	<20130610.141816.1546753299816672552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56988 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3FJVsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 17:48:19 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp12so3177635pab.21
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 14:48:18 -0700 (PDT)
In-Reply-To: <20130610.141816.1546753299816672552.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was trying to split them into net and net-next series.
If I sent one series, would you be able to handle that?
