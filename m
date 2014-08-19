From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Lost ping responses
Date: Tue, 19 Aug 2014 11:35:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1747B268@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1747B1C0@AcuExch.aculab.com>
 <53F331B4.10802@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Jamal Hadi Salim' <jhs@mojatatu.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39468 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750911AbaHSLgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 07:36:23 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29372-10 for <netdev@vger.kernel.org>;
 Tue, 19 Aug 2014 12:36:13 +0100 (BST)
In-Reply-To: <53F331B4.10802@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim

> > Any ideas how to find out where the discards are happening?
> > It might just be somewhere that would affect other traffic flows.
> 
> netstat -s

Thanks - 'Ip: outgoing packets dropped' increments for every lost response.

Next step is to work out what that means...

	David
