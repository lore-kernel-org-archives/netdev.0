From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on
 a Linux machine
Date: Tue, 11 May 2004 12:53:46 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com>
References: <40A11644.7090402@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, snortwiz@hotmail.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <40A11644.7090402@us.ibm.com>
To: niv@us.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Routing is something done between different hosts. Hosts normally
will accept packets for any local  address, regardless of
which interface it was received on.

That's not a bug; that's how almost everything works.

                                +-DLS
