From: Jeff Garzik <jgarzik@pobox.com>
Subject: Note on wireless development process
Date: Tue, 22 Mar 2005 21:29:16 -0500
Message-ID: <4240D47C.8090707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Just a general note...  like many other areas of the kernel, there is no 
wireless roadmap.  There is a set of technical criteria (see '2.6.x 
wireless update and status' post), but there is no One True Path to 
follow to get there.

People interested in working on wireless need to be their own guides, 
and find their own path.  There has been endless discussion on wireless, 
and not much movement.  So asking questions without attaching a patch 
won't get very far.  The general process is just like any other kernel 
development process:  post a patch, get feedback, revise patch, lather 
rinse repeat.

Don't wait for DaveM or me to suddenly post reams of wireless code.  I'm 
speculating about David's time, but I'm just too darned busy.  David and 
I play the roles of reviewer and advisor.  It's up to YOU to "scratch 
the itch" and get world-class wireless support into Linux.

With regards to development process, the main point of coordination is 
the wireless-2.6 queue itself, not a human.  Look at the wireless-2.6 
tree, consider what your next step is, and go there.  Don't bother 
thinking too much about code outside that tree (and upstream).

Please direct questions and comments to the netdev@oss.sgi.com mailing 
list, rather than privately emailing me or DaveM.  That way knowledge is 
shared, debated, and archived.

	Jeff
