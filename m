From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/6] A step closer to RFC 6458 compliancy
Date: Tue, 17 Jun 2014 15:14:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725DE4C@AcuExch.aculab.com>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Geir Ola Vaagland' <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:52688 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S933339AbaFQPPn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 11:15:43 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00483-10 for <netdev@vger.kernel.org>;
 Tue, 17 Jun 2014 16:15:34 +0100 (BST)
In-Reply-To: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geir Ola Vaagland
> These patches are part of my master thesis project. I have been searching for discrepancies between
> the socket API specificiation in RFC 6458 and the current Linux SCTP implementation. The following
> patches are my humble attempts at getting somewhat closer to compliancy.

You should keep commit messages with 80 columns.
The message subject should say that this is 'v2'.
You still haven't fixed all the code style issues.
This email should include a list of the differences from the earlier version.

	David
