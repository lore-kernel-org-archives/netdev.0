From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6.0-test11: dst_cache_overflow causing unresponsive box
Date: 02 Dec 2003 07:47:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1070369223.1027.34.camel@jzny.localdomain>
References: <072501c3b874$2542ae70$15fea8c0@fortress>
	 <16332.27919.502097.988522@robur.slu.se>
	 <20031202032606.28db927b.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, francois@baligant.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031202032606.28db927b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


With that many flows the neighbor cache gc may also be killing him.

cheers,
jamal
