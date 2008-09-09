From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: Extend smc911x to support LAN921x chips - differences?
Date: Tue, 09 Sep 2008 22:08:43 +0200
Message-ID: <87vdx5gjzo.fsf@macbook.be.48ers.dk>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:24380 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbYIIUIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 16:08:52 -0400
Received: by ug-out-1314.google.com with SMTP id k3so274727ugf.37
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 13:08:50 -0700 (PDT)
In-Reply-To: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com> (Steve Glendinning's message of "Tue\, 9 Sep 2008 16\:26\:35 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Steve" == Steve Glendinning <Steve.Glendinning@smsc.com> writes:

Hi,

 Steve> Did you have the in-tree driver succesfully working with LAN9115?

I've used the mainline driver without problems on various PPC boards
with LAN9117 devices..

 Steve> The vast majority of users i've worked with have ended up
 Steve> using the out-of-tree smsc911x driver, as it "just works" on
 Steve> many platforms.  I'll be re-submitting another candidate when
 Steve> I've finished working on the LAN9500 USB ethernet driver, but
 Steve> for now the latest submission:

I've said a few times already, but couldn't you fix the existing
driver instead of adding a completely new one?

-- 
Bye, Peter Korsgaard
