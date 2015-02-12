From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH next v3 3/6] bonding: Implement port churn-machine (AD
 standard 43.4.17).
Date: Thu, 12 Feb 2015 09:58:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAE2BA6@AcuExch.aculab.com>
References: <1423715066-9345-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: 'Mahesh Bandewar' <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Veaceslav Falico" <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:58577 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321AbbBLJ7a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 04:59:30 -0500
In-Reply-To: <1423715066-9345-1-git-send-email-maheshb@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bandewar
> The Chrun Detection machines detect the situation where a port is operable,
      ^^^^^ spelling

> but the Actor and Partner have not attached the link to an Aggregator and
> brought the link into operation within a bound time period. Under normal
> operation of the LACP, aggrement between Actor and Partner should be reached
> very rapidly. Continued failure to reach aggrement can be symptomatic of
> device failure.
...
