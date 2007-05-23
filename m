From: "Tony Petz" <agoston.petz@gmail.com>
Subject: Running multiple concurrent TCP stacks
Date: Wed, 23 May 2007 16:59:02 -0500
Message-ID: <103513710705231459l49add2a6xa9c4609d11e478a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:16971 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756245AbXEWV7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 17:59:07 -0400
Received: by an-out-0708.google.com with SMTP id d31so102618and
        for <netdev@vger.kernel.org>; Wed, 23 May 2007 14:59:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm working on a research project that requires two simultaneously
running but independent TCP implementations.  Searching the archives I
was only able to come up with this:
http://www.spinics.net/lists/linux-net/msg09064.html

I was wondering if anyone had any insight into the problem, or knew of
a good place to start looking at how to load two copies of TCP stack,
probably bound to two different interfaces for simplicity.

Any advice appreciated...
-tony
