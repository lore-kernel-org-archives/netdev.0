From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH NEXT 3/5] qlcnic: vlan lro support
Date: Thu, 16 Sep 2010 15:27:18 +0200
Message-ID: <1284643638.3352.30.camel@edumazet-laptop>
References: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
	 <1284642872-27832-4-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36887 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab0IPN1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 09:27:23 -0400
Received: by ewy23 with SMTP id 23so528211ewy.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 06:27:22 -0700 (PDT)
In-Reply-To: <1284642872-27832-4-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 septembre 2010 =C3=A0 06:14 -0700, Amit Kumar Salecha a =C3=
=A9crit :
> LRO + GRO + vlan rx accleration support, performance increases
> around 20% and cpu utilization reduces around 70% on vlan interface.

Interesting. What is the workload that demonstrates such gains ?


