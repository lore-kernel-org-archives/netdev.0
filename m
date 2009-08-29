From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH] sky2: Don't try to turn led off in sky2_down()
Date: Sat, 29 Aug 2009 22:17:57 +0900
Message-ID: <4A992A85.4080101@ring3k.org>
References: <4A9928C9.7000907@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:51963 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbZH2NVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 09:21:48 -0400
Received: by iwn42 with SMTP id 42so1234147iwn.33
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 06:21:50 -0700 (PDT)
In-Reply-To: <4A9928C9.7000907@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike McCormack wrote:
> There are a few problems with the following line of code in sky2_down()

Apologies, there probably should have been a "next" in that subject line. 

Mike
