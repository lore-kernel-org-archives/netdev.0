From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: snmp stats as %ld or %lu
Date: Wed, 2 Apr 2003 12:27:55 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030402122755.5dc3f022.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

ipv4/proc.c prints SNMP stats using %lu,
but ipv6/proc.c prints them using %ld.

Is this difference intentional, planned, or an oversight,
or something else?

Thanks,
--
~Randy
