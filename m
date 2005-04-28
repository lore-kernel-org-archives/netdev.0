From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 6/6][SCTP] Fix SCTP sendbuffer accouting.
Date: Thu, 28 Apr 2005 12:02:29 -0700
Message-ID: <20050428120229.76c43c44.davem@davemloft.net>
References: <Pine.LNX.4.58.0504261121040.6387@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0504261121040.6387@dyn9047018105.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


All 6 patches applied, with the one modification that I've made
per-socket accounting be the default as discussed with you in
private email.

Please do the same when you submit your 2.4.x patches.

Thanks a lot.
