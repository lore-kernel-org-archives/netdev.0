From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] iproute2 release
Date: Thu, 10 Mar 2005 11:24:23 -0800
Message-ID: <20050310112423.7afdd095@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
To: linux-net@vger.kernel.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor update release for iproute2 is available.

http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.11-050310.tar.gz

Also, this time it unpacks to the right name. 

Stephen Hemminger 

	* fix pkt_cls.h to have tc_u32_mark
	* update include files to be stripped versions of 2.6.11
	* add documentation about netem distributions [from nistnet]
	* turn off nup in document make [from FC3]
	* don't build with extra debug info (-g) [from FC3]
	
Nix 
	* make man3 directory
	
Pasi 
	
	* add ESP-in-UDP encapsulation

Thomas Graf 
	* [NETEM] Fix off by one
	* [NEIGH] print number of probes done so far (statistics mode only)
	
Herbert Xu 
	* Trivial typo in ip help
