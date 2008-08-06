From: "Tobias Koeck" <tobias.koeck@gmail.com>
Subject: hash_list and rcu locking question
Date: Wed, 6 Aug 2008 17:56:43 +0200
Message-ID: <379e30200808060856h112ec1d6x2b7ec6497a32de09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:4144 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030407AbYHFP4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 11:56:45 -0400
Received: by fg-out-1718.google.com with SMTP id 19so10402fgg.17
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 08:56:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are the hash_list rcu functions avoiding all locking problems (even
the one with only one CPU)?

Are there some abstract examples for the use of the hash_{head,list} structures?

Greetz and thanks
t.
