From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] proportional share accept()
Date: Wed, 25 Feb 2004 09:21:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225092116.2081ddfb@dell_ss3.pdx.osdl.net>
References: <Pine.LNX.4.44.0402250818060.2878-100000@loopback.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vivek Kashyap <kashyapv@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0402250818060.2878-100000@loopback.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just a cursory question, but would it be possible to just use iptables
to classify the packets and assign them to different IP addresses.
The the application could manage the priorities by opening two different
sockets (bound to different IP addresses) and do the scheduling there?
