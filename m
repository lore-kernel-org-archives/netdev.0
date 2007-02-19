From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Tue, 20 Feb 2007 00:50:08 +0100
Message-ID: <45DA37B0.5020209@gmail.com>
References: <45D97D5D.9040101@gmail.com> <45D97DC9.1030305@gmail.com> <45DA0FD6.9020404@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>,
	David Miller <davem@davemloft.net>
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:65509 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965558AbXBSXuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 18:50:13 -0500
Received: by mu-out-0910.google.com with SMTP id g7so608461muf
        for <netdev@vger.kernel.org>; Mon, 19 Feb 2007 15:50:12 -0800 (PST)
In-Reply-To: <45DA0FD6.9020404@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner ha scritto:
> Note the patch is compile-tested only!  I can do some real testing if 
> you'd like to apply this Dave.
The date you read on the patch is due to the fact I've splitted this 
patchset into 2 diff files. This isn't compile-tested only, I've used 
this piece of code for about 3 months.

However more testing is good and welcome.

Regards,
Angelo P. Castellani
