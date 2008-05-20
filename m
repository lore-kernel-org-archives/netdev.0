From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: Oops in fs_enet driver with preempt-rt
Date: Tue, 20 May 2008 13:53:23 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B046E752B@ismail.innsys.innovsys.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B046E728C@ismail.innsys.innovsys.com> <DCEAAC0833DD314AB0B58112AD99B93B046E72C3@ismail.innsys.innovsys.com> <4832F139.1020502@freescale.com> <DCEAAC0833DD314AB0B58112AD99B93B046E73C6@ismail.innsys.innovsys.com> <4832FA80.7060807@freescale.com> <DCEAAC0833DD314AB0B58112AD99B93B046E73EC@ismail.innsys.innovsys.com> <998DABA0-38B6-43C3-A788-307AA8D52F17@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Scott Wood" <scottwood@freescale.com>, <linuxppc-dev@ozlabs.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.innovsys.com ([66.115.232.196]:15552 "EHLO
	mail.innovsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755701AbYETSw4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 14:52:56 -0400
Content-class: urn:content-classes:message
In-Reply-To: <998DABA0-38B6-43C3-A788-307AA8D52F17@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
>> Rune Torgersen wrote:
>> That worked. Console output is sane again.
> 
> I'm hoping to see some patches related to these fixes :)

Working on it.
