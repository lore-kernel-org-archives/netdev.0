From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 2.6.16-060323
Date: Thu, 23 Mar 2006 14:32:49 -0800
Message-ID: <20060323143249.55250ad8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	LARTC <lartc@mailman.ds9a.nl>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New version of iproute2 is available. No major changes, mostly just
small bug fixes.
	http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.16-060323.tar.gz

James Lentini
   Increase size of hw address allowed for ip neigh to allow for IB.

Russell Stuart
   Fix missing memset in tc sample
   Add sample divisor

Alpt
   Add more rt_proto values

Dale Sedivec
   Warn when using "handle" instead of "classid" with "tc class"

Jean Tourrilhes
   Fix endless loop in netlink error handling

Stephen Hemminger
   Change default lnstat count to 1
   Update to 2.6.16 headers
   Add fake version of include/linux/socket.h to fix warnings


