From: "Jie Xu" <jiee.xu@gmail.com>
Subject: how to change the initial queue descipline to netem?
Date: Fri, 8 Dec 2006 16:14:23 +0800
Message-ID: <b7c8741d0612080014i300d7cafj745a661c5ec9829d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.229]:15150 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425153AbWLHIOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 03:14:25 -0500
Received: by hu-out-0506.google.com with SMTP id 23so313400huc
        for <netdev@vger.kernel.org>; Fri, 08 Dec 2006 00:14:24 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the main problem is that how to create a netem queue?
just replace the fifo_fast in dev_activate() failed
