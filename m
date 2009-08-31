From: Lisong Xu <lisongxu2@gmail.com>
Subject: TCP Congestion Control Algorithms
Date: Mon, 31 Aug 2009 16:10:59 -0500
Message-ID: <a45e9b40908311410m486a60fel6a81c334732de358@mail.gmail.com>
References: <a45e9b40908311408l15d68088i459d6a1000cbca07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f175.google.com ([209.85.222.175]:65409 "EHLO
	mail-pz0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbZHaVK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 17:10:56 -0400
Received: by pzk5 with SMTP id 5so3116798pzk.21
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 14:10:59 -0700 (PDT)
In-Reply-To: <a45e9b40908311408l15d68088i459d6a1000cbca07@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Since there are multiple different TCP congestion control algorithms
available in Linux, a Linux server may use any of them.

Is it possible for a regular user to find out the exact TCP congestion
control algorithm used by a Linux server? For example, if I am
downloading a file from a remote Linux server using a TCP flow, can I
find out whether this flow is a TCP/CUBIC flow, or TCP/Newreno, or
some other TCP protocol?

Thanks! If I send this email to a wrong mailing list, I am sorry for that.

Lisong
