From: "David Laight" <David.Laight@ACULAB.COM>
Subject: git problems
Date: Tue, 17 Dec 2013 17:21:05 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B74A0@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33793 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752800Ab3LQRWa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 12:22:30 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10375-05 for <netdev@vger.kernel.org>;
 Tue, 17 Dec 2013 17:22:28 +0000 (GMT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git managed to completely trash my tree - no problem I'd saved everything important.
So I renamed the directory tree and then checked out an entire new tree.
Now it won't let me commit because it has somewhere remembered a merge f*ckup
in the old tree.
Where has it got this info saved, and how do I tell it there is nothing wrong?

	David
