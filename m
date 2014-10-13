From: Angelo Dureghello <angelo70@gmail.com>
Subject: Fwd: micrel: ksz8051 badly detected as ksz8031
Date: Mon, 13 Oct 2014 13:23:33 +0200
Message-ID: <543BB635.80608@gmail.com>
References: <543A7A2A.5040700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:64435 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbaJMLXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 07:23:36 -0400
Received: by mail-wi0-f179.google.com with SMTP id d1so7157843wiv.0
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 04:23:35 -0700 (PDT)
Received: from [192.168.0.2] (host155-25-dynamic.14-87-r.retail.telecomitalia.it. [87.14.25.155])
        by mx.google.com with ESMTPSA id ew1sm16295244wjb.31.2014.10.13.04.23.33
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Oct 2014 04:23:34 -0700 (PDT)
In-Reply-To: <543A7A2A.5040700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



I confirm this seems to be an issue of recent versions of kernel driver 
"micrel.c".

I just compiled kernel 3.17.0 with micrel.c driver 3.5.1, link is up and 
running.

If you need debug info, or to test a patch, let me know.

Regards
angelo
