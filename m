From: Zdenek Radouch <zdenek@rcn.com>
Subject: Do you know the linux TCP stack?
Date: Sat, 05 Mar 2005 09:31:32 -0500
Message-ID: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I ran out of ideas.  Can't find the answers in any docs,
and I don't have time to read and analyze the source right now.

I will hire you to help me; I need the following to be done in
my net device driver:

With the ARP disabled (this is well documented so I believe I've done that),
while queueing the physical output, I need to get hold of the IP address
of where the packet is being sent.  Yes, I mean IP address, not
Ethernet address, and yes this is not the destination addresses in
the IP header.

If you can do it, and are interested in helping me,  please send me
a note, with your hourly consulting rate, or a suggestion of how
you'd like to be compensated for the work.  Of course, if you'd
like to just send me an answer, that would be fine, too. :-)
Thanks.

-Zdenek
