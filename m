From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Wed, 7 Jul 2004 11:10:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	<20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	<1088824432.1043.271.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Catalin BOIE
 <util@deuroconsult.ro>,
        netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1088824432.1043.271.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok, I'll bite how would you do:

Rate limit packet egress on a ethernet device (eth0) so it looks like a slow DSL link (25 Kbps)
by not dropping packets but by pacing the data.
