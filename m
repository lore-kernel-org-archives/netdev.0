From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Huaei E3131 - connected!
Date: Wed, 3 Jul 2013 08:40:16 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307030836270.12831@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:63915 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551Ab3GCGkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 02:40:00 -0400
Received: by mail-ea0-f177.google.com with SMTP id j14so3175478eak.8
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 23:39:59 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.02.1307022213380.26010@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys!
there's a problem ... I don't understand why even looking at the code (sure, I 
will look at it again): but, bringing up the wwan0 interface simply works. So 
now I'm sending this mail via the device's wwan interface and while looking and 
typing to the wdm character device, without any apparent problem.
I did not implement the status handler, but the driver seems to be able to 
work, probably missing some notifications?
This needs to be EXTRENSIVELY polished and reviewed - but it's encouraging!
