From: "Andrew Hall" <andrew.a.hall@gmail.com>
Subject: Accessing certain web sites broken from 2.6.19+
Date: Fri, 11 May 2007 14:23:25 +1000
Message-ID: <4643efc2.7cb1b0b0.2a08.4658@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:47354 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699AbXEKEXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 00:23:32 -0400
Received: by py-out-1112.google.com with SMTP id a29so680161pyi
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 21:23:31 -0700 (PDT)
Content-Language: en-au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When accessing certain web sites when using any kernel above 2.6.19, TCP
seems to break. Connection to the site is established but never completes.
One particular site is www.dcita.gov.au. Is there a known issue pertaining
to this? Using any kernel below 2.6.19 (for example: 2.6.12 or 2.6.15) works
fine.

