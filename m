From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Wed, 11 Jun 2003 11:54:34 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16102.64602.19145.131439@robur.slu.se>
References: <20030610.085600.71109220.davem@redhat.com>
	<Pine.LNX.4.44.0306101815550.26879-100000@kenzo.iwr.uni-heidelberg.de>
	<20030610164949.GB13246@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
	"David S. Miller" <davem@redhat.com>, sim@netnation.com,
	ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030610164949.GB13246@wotan.suse.de>
List-Id: netdev.vger.kernel.org



Andi Kleen writes:

 > You can play some tricks with the driver to make eth_type_trans disappear
 > from the profiles. This usually helps a lot because it avoids one
 > full "fetch from cache cold memory" roundtrip per packet, which is slow on
 > any CPU.


 Andi!
 Interesting. Can we get into details?

 Cheers.

						--ro

