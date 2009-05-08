From: Dan McDonald <danmcd@sun.com>
Subject: [danmcd@sun.com: [Ipsec-tools-devel] SHA-2 and RFC 4868]
Date: Fri, 8 May 2009 14:08:11 -0400
Message-ID: <20090508180811.GA15999@kebe.East.Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan McDonald <danmcd@sun.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-ea-mail-2.Sun.COM ([192.18.43.25]:63547 "EHLO
	sca-ea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599AbZEHS1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 14:27:38 -0400
Received: from dm-east-02.east.sun.com ([129.148.13.5])
	by sca-ea-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n48IFhXi014331
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 18:15:43 GMT
Received: from kebe.East.Sun.COM (kebe.East.Sun.COM [129.148.174.48])
	by dm-east-02.east.sun.com (8.13.8+Sun/8.13.8/ENSMAIL,v2.2) with ESMTP id n48IFhk7050511
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 14:15:43 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pardon the top-post.  Paul Moore suggested this mailing list as the best
place to ask the following.

Thanks,
Dan McD.

----- Forwarded message from Dan McDonald <danmcd@sun.com> -----

Date: Thu, 07 May 2009 15:57:39 -0400
From: Dan McDonald <danmcd@sun.com>
To: ipsec-tools-devel@lists.sourceforge.net
Subject: [Ipsec-tools-devel] SHA-2 and RFC 4868
User-Agent: Mutt/1.5.19 (2009-01-05)

Not sure if this is the most appropriate list for the topic, but I'm sure
enough actual AH/ESP implementors hang out here.

I've noticed at least one other platform doesn't do SHA-2 per RFC 4868
(half-sized hash truncation), and instead truncates the SHA-2 hashes to
96-bits like MD5 and SHA1.

Is this just me, or is there an unfixed kernel problem in other platforms'
AH/ESP code?

Thanks,
Dan

------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
_______________________________________________
Ipsec-tools-devel mailing list
Ipsec-tools-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel

----- End forwarded message -----
