From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2-2.6.11-050314
Date: Mon, 14 Mar 2005 16:34:38 -0800
Message-ID: <20050314163438.1f73ec6d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: linux-net@vger.kernel.org, lartc@mailman.ds9a.nl
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

New version of Iproute2 is available:

http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.11-050314.tar.gz

Changes:

Boian Bonev
	TC batch mode to read commands from file.  

Thomas Graf
	ip link command displays carrier status

Patrick McHardy
	use user hz

Jamal Hadi Salim 
	Fix ipt registration

Me
	Batch mode cleanup.
	IP tables build fix
