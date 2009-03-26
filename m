From: Adam Richter <adam_richter2004@yahoo.com>
Subject: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Wed, 25 Mar 2009 17:06:03 -0700 (PDT)
Message-ID: <332981.79226.qm@web57706.mail.re3.yahoo.com>
Reply-To: adam_richter2004@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: berkley@cs.wustl.edu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web57706.mail.re3.yahoo.com ([68.142.236.69]:32868 "HELO
	web57706.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752730AbZCZAGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 20:06:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In addition to seeing the problem with CONFIG_FORCEDETH_NAPI disabled,
I have now reproduced the problem with that configuration option enabled.  So, NAPI might not be the problem at all.

Adam Richter



      
