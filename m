From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Fri, 13 Jun 2003 12:22:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16105.42475.451956.130322@robur.slu.se>
References: <16102.9418.43884.336925@robur.slu.se>
	<20030610.115759.26513736.davem@redhat.com>
	<16103.27039.204333.952703@robur.slu.se>
	<20030612.223818.74754074.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, ralph@istop.com,
   hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030612.223818.74754074.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:
 >    From: Robert Olsson <Robert.Olsson@data.slu.se>
 >    Date: Wed, 11 Jun 2003 19:40:47 +0200
 > 
 >    vma      samples  %-age       symbol name
 >    c023c038 107340   33.143      fn_hash_lookup
 > 
 > Ok, let's optimize our datastructures for how we actually
 > use them :-)  Also, fn_zone shrunk by 8 bytes.
 > 
 > Try this:

 I'll pass the university lab on my way home later today and hope give 
 to it a try.

 Cheers.
					--ro
