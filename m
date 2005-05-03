From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4 6/6][SCTP] Fix SCTP sendbuffer accouting.
Date: Tue, 3 May 2005 14:41:15 -0700
Message-ID: <20050503144115.0d03ae87.davem@davemloft.net>
References: <Pine.LNX.4.58.0504261205200.8399@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0504261205200.8399@dyn9047018105.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Sridhar, I will apply all of these as soon as Marcelo has
his GIT tree setup for the 2.4.x kernel.

They all look perfectly fine and thanks for remembering
to update the default sysctl setting for socket based
accounting.
