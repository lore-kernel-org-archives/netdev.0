From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][v3.2.y] xen-netfront: delay gARP until backend switches to
 Connected
Date: Fri, 15 Mar 2013 13:56:45 -0400
Message-ID: <514360DD.8050406@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, jeremy@goop.org,
	xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please consider including upstream commit 
08e34eb14fe4cfd934b5c169a7682a969457c4ea in the next v3.2.y release.
It was included upstream as of v3.3-rc1.  It has been tested and 
confirmed to resolve http://bugs.launchpad.net/bugs/1154608 .

commit 08e34eb14fe4cfd934b5c169a7682a969457c4ea
Author: Laszlo Ersek <lersek@redhat.com>
Date:   Sun Dec 11 01:48:59 2011 +0000

     xen-netfront: delay gARP until backend switches to Connected


Sincerely,

Joseph Salisbury
