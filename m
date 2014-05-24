From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: which git repo to use for new network driver
Date: Sat, 24 May 2014 16:41:40 +0200
Message-ID: <5380AFA4.1090708@hartkopp.net>
References: <CAJ3bTp5CsoWPmpQQ90o5M7DFQR_WZ3o5XkeVDN3aQMJKBr7kbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Rayagond Kokatanur <rayagond@vayavyalabs.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.161]:26514 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaEXOlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 10:41:44 -0400
In-Reply-To: <CAJ3bTp5CsoWPmpQQ90o5M7DFQR_WZ3o5XkeVDN3aQMJKBr7kbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 24.05.2014 16:37, Rayagond Kokatanur wrote:
> Hi All,
> 
> Which git repo should be used for developing new network driver,
> net-next.git or net.git.

New drivers and features always go via net-next.
The net-tree is just for fixes.

If you have e.g. a new wireless/bluetooth/CAN driver there's a
wireless/bluetooth/CAN mailing list to post to alternatively.

Regards,
Oliver
