From: "Bryan O'Sullivan" <bos@keyresearch.com>
Subject: [ANNOUNCE] netplug, a daemon that handles network cables getting
	plugged in and out
Date: 28 Aug 2003 14:21:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Netplug is a daemon that responds to network cables being plugged in or
out by bringing a network interface up or down.  This is extremely
useful for DHCP-managed systems that move around a lot, such as laptops
and systems in cluster environments.

For more details and download instructions, see the netplug homepage:
http://www.red-bean.com/~bos/

	<b
