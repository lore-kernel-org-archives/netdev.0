From: Florin Andrei <florin@andrei.myip.org>
Subject: stateless 1:1 NAT
Date: Tue, 16 Oct 2007 17:29:21 -0700
Message-ID: <47155761.9030404@andrei.myip.org>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:24808 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1765695AbXJQAgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 20:36:04 -0400
Received: from localhost (weiqi.home.local [127.0.0.1])
	by weiqi.home.local (Postfix) with ESMTP id C20325770DB
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 17:29:22 -0700 (PDT)
Received: from weiqi.home.local ([127.0.0.1])
	by localhost (andrei.myip.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xgN0Xm0Z55tF for <netdev@vger.kernel.org>;
	Tue, 16 Oct 2007 17:29:21 -0700 (PDT)
Received: from valar.sanjose.telcontar.com (unknown [192.168.2.2])
	by weiqi.home.local (Postfix) with ESMTP id C9205577092
	for <netdev@vger.kernel.org>; Tue, 16 Oct 2007 17:29:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've heard that stateless 1:1 NAT will be possible with the upcoming 
2.6.24 kernel.
I'd like to test that feature, but I'm not sure when it will actually be 
included. Will it be present in the release candidates for 2.6.24?
I just need a somewhat stable kernel tree to play with.

-- 
Florin Andrei

http://florin.myip.org/
