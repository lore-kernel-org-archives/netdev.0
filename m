From: Brad Johnson <bjohnson@ecessa.com>
Subject: Possible to add netfilter hooks to IFB driver?
Date: Tue, 03 Sep 2013 16:26:09 -0500
Message-ID: <522653F1.6090902@ecessa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:47151 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab3ICV0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 17:26:16 -0400
Received: by mail-oa0-f51.google.com with SMTP id h1so7288061oag.38
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 14:26:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to add netfilter hooks to the IFB driver so I can do 
iptables -j IFB (just like we can with IMQ). But I would like to know 
first if there are any reasons this can not work. Please advise if this 
is possible, and if so any tips would be appreciated.

Cheers,
Brad
