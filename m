From: Stephen Hemminger <shemminger@osdl.org>
Subject: [announce] new iproute2 snapshot
Date: Tue, 31 Aug 2004 10:59:30 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040831105930.6766ddc1@dell_ss3.pdx.osdl.net>
References: <1093796043.1077.386.camel@jzny.localdomain>
	<1093796588.1073.398.camel@jzny.localdomain>
	<20040830151234.6103757b@dell_ss3.pdx.osdl.net>
	<1093904731.1036.17.camel@jzny.localdomain>
	<20040830153723.05645bcf@dell_ss3.pdx.osdl.net>
	<1093918395.1043.57.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: hadi@znyx.com, "David S. Miller" <davem@redhat.com>
In-Reply-To: <1093918395.1043.57.camel@jzny.localdomain>
List-Id: netdev.vger.kernel.org

A new version of iproute2 utilities is available:
http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.9-ss040831.tar.gz

This version includes:
	* support for the latest version on netem
	  For more info on netem, see:
		http://developer.osdl.org/shemminger/netem

	* jamal's changes for tc actions and more tc_stats
	* several other small cleanup patches

I'll make a final version after 2.6.9 is released.

