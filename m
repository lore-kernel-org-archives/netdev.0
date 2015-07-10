From: Phani <pgargey@yahoo.com>
Subject: Re: Kernel Oops in =?utf-8?b?X19pbmV0X3R3c2tfa2lsbCgp?=
Date: Fri, 10 Jul 2015 16:36:45 +0000 (UTC)
Message-ID: <loom.20150710T183514-452@post.gmane.org>
References: <545A49B4.7090107@iogearbox.net> <CAHA+R7PAdVS=TBd8ZDAW3wdadjNEVjiyemrs54wNp8fdtCMvZQ@mail.gmail.com> <FB8A4655DFD2B34DB16AE06DDDD6C0E231A71CE3@SJEXCHMB12.corp.ad.broadcom.com> <20141105.143929.861274469992898400.davem@davemloft.net> <FB8A4655DFD2B34DB16AE06DDDD6C0E231A72A4B@SJEXCHMB12.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36735 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754675AbbGJQkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 12:40:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ZDbLJ-0005aU-Iq
	for netdev@vger.kernel.org; Fri, 10 Jul 2015 18:40:05 +0200
Received: from sp6.qualcomm.com ([199.106.103.56])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 18:40:05 +0200
Received: from pgargey by sp6.qualcomm.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 18:40:05 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 
> > The problem has been fixed. It is introduced by a third party patch,
> > which decreases the refcnt of timewait socket.
>



What is the fix?
pl share the gerrit.
