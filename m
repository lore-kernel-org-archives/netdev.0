From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH v3] CDC NCM: release interfaces fix in unbind()
Date: Tue, 24 May 2011 15:32:22 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3BAF4C5F@EXDCVYMBSTM006.EQ1STM.local>
References: <1305938536-5343-1-git-send-email-alexey.orishko@stericsson.com>
 <20110523.174647.1404735155326791304.davem@davemloft.net>
 <201105241527.30270.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"gregkh@suse.de" <gregkh@suse.de>,
	"stern@rowland.harvard.edu" <stern@rowland.harvard.edu>
To: Oliver Neukum <oneukum@suse.de>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:49671 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756371Ab1EXNcx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 09:32:53 -0400
In-Reply-To: <201105241527.30270.oneukum@suse.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Oliver Neukum [mailto:oneukum@suse.de]
> >
> > Oliver, this look good to you?
> 
> I'd like to see intfdata set to NULL before an interface is unclaimed.
> 
> 	Regards
> 		Oliver

I'll update it shortly and post it.

BR Alexey
