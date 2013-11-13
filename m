From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] 6lowpan: Uncompression of traffic class field was
 incorrect
Date: Wed, 13 Nov 2013 10:14:51 +0100
Message-ID: <20131113091450.GA3150@omega>
References: <1384333419-4087-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:52190 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759025Ab3KMJO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 04:14:59 -0500
Received: by mail-bk0-f49.google.com with SMTP id w14so223013bkz.22
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 01:14:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1384333419-4087-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

I know there are some issues with traffic class 
compression/uncompression, but I didn't have time to dig into it.
That's all what I can say now about traffic class issue. Maybe there are
more than one issues or not, I need to dig into the code. :-)


Another note:
Since we known you don't need the fragmentation api accroding rfc4944
for blte 6lowpan I will send the udp fixes in the next days, so then you
can work with it and maybe we can share some code.

- Alex
